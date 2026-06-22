import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:memory_game/constant/app_links.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/premium_constant.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:memory_game/constant/text_style.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:memory_game/services/premium_service.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/view/util/pressable.dart';
import 'package:memory_game/view/util/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// プレミアム（広告非表示）のペイウォールをフルスクリーンで表示する。
Future<void> showPaywall(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const PaywallView(),
    ),
  );
}

/// ペイウォールの自動表示（広告が出る前のタイミング）を制御する。
///
/// 十分に遊んだ無料ユーザーへ、インタースティシャル広告で体験が途切れる前に
/// 「広告を消せます」と控えめに提案する。高齢者ターゲットのため、しつこく
/// 出さないよう「最低プレイ回数・最大表示回数・最小間隔」で抑制する。
class PaywallTrigger {
  const PaywallTrigger._();

  /// この回数以上遊んだユーザーにのみ提案する（アプリを気に入っている段階）。
  static const int _minPlays = 4;

  /// 生涯で自動表示する最大回数（しつこさ回避）。
  static const int _maxAutoShows = 2;

  /// 自動表示の最小間隔。
  static const Duration _minInterval = Duration(days: 5);

  /// 条件を満たせばペイウォールを表示する。表示したら true を返す。
  ///
  /// [totalPlays] は全期間の総プレイ回数（エンゲージメントの指標）。
  static Future<bool> maybeShowBeforeAd(
    BuildContext context,
    int totalPlays,
  ) async {
    // プレミアム・非対応プラットフォームでは出さない。
    if (!iapSupported) return false;
    if (PremiumService.instance.isPremium.value) return false;
    // 遊び込んでいないユーザーには出さない。
    if (totalPlays < _minPlays) return false;

    final prefs = await SharedPreferences.getInstance();

    final count = prefs.getInt(SpKey.paywallShownCount.name) ?? 0;
    if (count >= _maxAutoShows) return false;

    final lastMillis = prefs.getInt(SpKey.paywallLastShown.name);
    if (lastMillis != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMillis);
      if (DateTime.now().difference(last) < _minInterval) return false;
    }

    // 表示を記録してから出す（連続表示・二重表示を防ぐ）。
    await prefs.setInt(
      SpKey.paywallLastShown.name,
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.setInt(SpKey.paywallShownCount.name, count + 1);

    if (!context.mounted) return false;
    await showPaywall(context);
    return true;
  }
}

class PaywallView extends StatefulWidget {
  const PaywallView({super.key});

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<PaywallView> {
  ScaffoldMessengerState? _messenger;

  @override
  void initState() {
    super.initState();
    // 購入・復元でプレミアムになったら、お礼を出して自動で閉じる。
    PremiumService.instance.isPremium.addListener(_onPremiumChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 画面を閉じた後でも出せるよう、アプリ直下の Messenger を保持しておく。
    _messenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    PremiumService.instance.isPremium.removeListener(_onPremiumChanged);
    super.dispose();
  }

  void _onPremiumChanged() {
    if (!mounted) return;
    if (!PremiumService.instance.isPremium.value) return;
    final thanks = AppLocalizations.of(context)!.premiumThanks;
    Navigator.of(context).maybePop();
    _messenger?.showSnackBar(SnackBar(content: Text(thanks)));
  }

  Future<void> _subscribe() async {
    final l10n = AppLocalizations.of(context)!;
    await PremiumService.instance.buyMonthly();
    // 商品が取得できない等で購入フローに入れなかった場合の案内。
    if (!mounted) return;
    if (PremiumService.instance.monthlyProduct.value == null &&
        !PremiumService.instance.purchasePending.value) {
      _messenger?.showSnackBar(SnackBar(content: Text(l10n.premiumUnavailable)));
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context)!;
    _messenger?.showSnackBar(
        SnackBar(content: Text(l10n.premiumRestoreChecking)));
    await PremiumService.instance.restore();
  }

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: DefColor.lightBeige,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.pagePadding,
              vertical: context.sectionGap,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 閉じる（×）ボタン。
                  Align(
                    alignment: Alignment.centerRight,
                    child: _CloseButton(onPressed: () => Navigator.pop(context)),
                  ),
                  SizedBox(height: context.sectionGap),
                  // 王冠アイコン（ゴールドの円）。
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: DefColor.select,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: DefColor.textWhite,
                        size: 52,
                      ),
                    ),
                  ),
                  SizedBox(height: context.sectionGap),
                  // 見出し。
                  Text(
                    l10n.premiumTitle,
                    textAlign: TextAlign.center,
                    style: AppText.title.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  // リード文。
                  Text(
                    l10n.premiumLead,
                    textAlign: TextAlign.center,
                    style: AppText.body,
                  ),
                  SizedBox(height: context.sectionGap),
                  // メリット一覧。
                  _BenefitRow(text: l10n.premiumBenefitNoAds),
                  _BenefitRow(text: l10n.premiumBenefitFocus),
                  _BenefitRow(text: l10n.premiumBenefitSupport),
                  SizedBox(height: context.sectionGap),
                  // 価格表示（ストアから取得できればローカライズ価格）。
                  ValueListenableBuilder<ProductDetails?>(
                    valueListenable: PremiumService.instance.monthlyProduct,
                    builder: (context, product, _) {
                      return Text(
                        l10n.premiumPrice(
                            product?.price ?? PremiumService.instance.priceText),
                        textAlign: TextAlign.center,
                        style: AppText.subheading.copyWith(fontSize: 22),
                      );
                    },
                  ),
                  SizedBox(height: context.sectionGap),
                  // 購入ボタン（進行中はスピナー）。
                  Center(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: PremiumService.instance.purchasePending,
                      builder: (context, pending, _) {
                        if (pending) {
                          return SizedBox(
                            height: context.buttonHeightFor(),
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: DefColor.selectDeep,
                                ),
                              ),
                            ),
                          );
                        }
                        return MyTextButton(
                          text: l10n.premiumSubscribe,
                          backColor: DefColor.select,
                          edgeColor: DefColor.selectDeep,
                          textColor: DefColor.textBlack,
                          widthRatio: 0.95,
                          onPressed: _subscribe,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 購入を復元。
                  TextButton(
                    onPressed: _restore,
                    child: Text(
                      l10n.premiumRestore,
                      style: AppText.bodyStrong.copyWith(
                        color: DefColor.darkBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: context.sectionGap),
                  // 自動更新・規約に関する注記。
                  Text(
                    l10n.premiumLegal,
                    textAlign: TextAlign.center,
                    style: AppText.recordDate.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  // 規約・プライバシーポリシーへのリンク。
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LinkText(
                        label: l10n.menuTerms,
                        onTap: () =>
                            _openUrl(AppLinks.termsOfService(locale)),
                      ),
                      Text('  ·  ', style: AppText.recordDate),
                      _LinkText(
                        label: l10n.menuPrivacy,
                        onTap: () =>
                            _openUrl(AppLinks.privacyPolicy(locale)),
                      ),
                    ],
                  ),
                  SizedBox(height: context.sectionGap),
                  // あとで（閉じる）。
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.premiumNotNow,
                        style: AppText.body.copyWith(color: DefColor.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// メリット1行（チェック＋テキスト）。
class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: DefColor.green, size: 26),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppText.bodyStrong)),
        ],
      ),
    );
  }
}

/// 右上の閉じる（×）丸ボタン。
class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const size = 44.0;
    const depth = 4.0;
    return SizedBox(
      width: size,
      height: size + depth,
      child: PressableButton(
        shape: BoxShape.circle,
        depth: depth,
        color: DefColor.darkBeige,
        haptic: PressHaptic.selection,
        onPressed: onPressed,
        child: const Icon(Icons.close_rounded,
            color: DefColor.textBlack, size: 24),
      ),
    );
  }
}

/// 下線付きの小さなリンクテキスト。
class _LinkText extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LinkText({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: AppText.recordDate.copyWith(
          fontSize: 13,
          color: DefColor.darkBlue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
