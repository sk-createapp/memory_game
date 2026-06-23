import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:memory_game/constant/app_links.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/premium_constant.dart';
import 'package:memory_game/constant/text_style.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:memory_game/services/premium_service.dart';
import 'package:memory_game/state/sound_setting_state.dart';
import 'package:memory_game/view/paywall.dart';
import 'package:memory_game/view/util/pressable.dart';

/// ホーム左上のメニューボタンから開く、アプリ共通のサイドメニュー。
///
/// 高齢者にも押しやすいよう大きめのタップ領域とはっきりした文字を用い、
/// アプリの暖色パレット（クリーム地・ティールのアイコン）に合わせている。
/// 項目は外部リンク（お問い合わせ・プライバシーポリシー・利用規約）、
/// ストアのレビュー導線、OSS ライセンス表示で構成する。
class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return Drawer(
      backgroundColor: DefColor.lightBeige,
      // 角を本アプリの丸みに合わせる。
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //ヘッダー（アプリ名 ＋「メニュー」ラベル）
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeGameTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 2),
                  Text(l10n.menuTitle, style: AppText.recordDate),
                ],
              ),
            ),
            _divider(),
            //メニュー項目
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  //プレミアム（広告非表示）への導線。状態に応じて表示が変わる。
                  const _PremiumMenuTile(),
                  //効果音（操作音・結果音）のオン/オフ切り替え。
                  const _SoundMenuTile(),
                  _MenuTile(
                    icon: Icons.mail_outline_rounded,
                    label: l10n.menuContact,
                    onTap: () => _openUrl(context, AppLinks.contactForm(locale)),
                  ),
                  _MenuTile(
                    icon: Icons.shield_outlined,
                    label: l10n.menuPrivacy,
                    onTap: () =>
                        _openUrl(context, AppLinks.privacyPolicy(locale)),
                  ),
                  _MenuTile(
                    icon: Icons.description_outlined,
                    label: l10n.menuTerms,
                    onTap: () =>
                        _openUrl(context, AppLinks.termsOfService(locale)),
                  ),
                  _MenuTile(
                    icon: Icons.info_outline_rounded,
                    label: l10n.menuLicenses,
                    onTap: () => _showLicenses(context, l10n),
                  ),
                ],
              ),
            ),
            _divider(),
            //フッター（著作権表示）
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 12, 22, 8),
              child: Text('© 2026 skcreation', style: AppText.recordDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: DefColor.darkBeige,
      );

  /// 外部URL（フォーム・法務ページ）をブラウザで開く。
  ///
  /// 先にメニューを閉じて操作感を軽くし、開けなかった場合のみ通知する。
  Future<void> _openUrl(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorText = AppLocalizations.of(context)!.menuOpenError;
    Navigator.of(context).pop();
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(errorText)));
    }
  }

  /// Flutter 標準の OSS ライセンス一覧を表示する。
  void _showLicenses(BuildContext context, AppLocalizations l10n) {
    Navigator.of(context).pop();
    showLicensePage(
      context: context,
      applicationName: l10n.homeGameTitle,
      applicationLegalese: '© 2026 skcreation',
    );
  }
}

/// プレミアム（広告非表示）のメニュー行。
///
/// 課金非対応プラットフォームでは出さない。未加入なら目を引くゴールドのチップで
/// ペイウォールへ誘導し、加入済みなら「プレミアム会員」のステータスを表示する。
class _PremiumMenuTile extends StatelessWidget {
  const _PremiumMenuTile();

  @override
  Widget build(BuildContext context) {
    if (!iapSupported) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<bool>(
      valueListenable: PremiumService.instance.isPremium,
      builder: (context, isPremium, _) {
        if (isPremium) {
          // 加入済み：タップでストアのサブスク管理（内容確認・解約）を開く。
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              firePressFeedback(PressHaptic.selection);
              Navigator.of(context).pop();
              _openManageSubscription();
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              child: Row(
                children: [
                  _chip(Icons.workspace_premium_rounded, DefColor.select,
                      DefColor.textWhite),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                l10n.premiumActive,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.bodyStrong,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle_rounded,
                                color: DefColor.green, size: 18),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.premiumManage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.recordDate
                              .copyWith(color: DefColor.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: DefColor.textMuted, size: 24),
                ],
              ),
            ),
          );
        }

        // 未加入：ペイウォールへ誘導する。
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            firePressFeedback(PressHaptic.selection);
            Navigator.of(context).pop();
            showPaywall(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Row(
              children: [
                _chip(Icons.workspace_premium_rounded, DefColor.select,
                    DefColor.textWhite),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.premiumMenuLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyStrong,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: DefColor.textMuted, size: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ストアのサブスク管理（内容確認・解約）ページを外部ブラウザ／ストアで開く。
  /// context を使わないため、ドロワーを閉じた後に安全に呼べる。
  Future<void> _openManageSubscription() async {
    final url = await PremiumService.instance.manageSubscriptionsUrl();
    if (url == null) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _chip(IconData icon, Color bg, Color fg) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: fg, size: 24),
      );
}

/// メニュー1項目分の行。丸いアイコンチップ＋ラベル＋シェブロンで構成する。
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        firePressFeedback(PressHaptic.selection);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: DefColor.lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: DefColor.darkBlueDeep, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodyStrong,
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: DefColor.textMuted, size: 24),
          ],
        ),
      ),
    );
  }
}

/// 効果音（操作音・結果音）のオン/オフを切り替えるメニュー行。
///
/// 行全体のタップでもスイッチ操作でも切り替えられ、高齢者にも分かりやすいよう
/// 大きなタップ領域とスピーカーのアイコンを用いる。設定値は永続化される。
class _SoundMenuTile extends ConsumerWidget {
  const _SoundMenuTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = ref.watch(soundEnabledProvider);

    void toggle() {
      // 切り替えの確認音は SoundService（オン時のみ）が鳴らすので、ここは触覚のみ。
      fireHaptic(PressHaptic.selection);
      ref.read(soundEnabledProvider.notifier).toggle();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: toggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: DefColor.lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                enabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: DefColor.darkBlueDeep,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.menuSound,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodyStrong,
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (_) => toggle(),
              activeTrackColor: DefColor.darkBlue,
            ),
          ],
        ),
      ),
    );
  }
}
