import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/text_style.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_game/constant/ad_constant.dart';
import 'package:memory_game/services/admob.dart';
import 'package:memory_game/services/consent_manager.dart';
import 'package:memory_game/services/notification_service.dart';
import 'package:memory_game/services/premium_service.dart';
import 'package:memory_game/services/sound_service.dart';
import 'package:memory_game/state/app_info_state.dart';
import 'package:memory_game/view/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 画面の向きを固定.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 効果音（操作音・結果音）の準備。設定読み込みとプレイヤー先読みを行う。
  // UIの起動はブロックしない。
  SoundService.instance.init();

  // 課金・広告の準備（対応プラットフォームのみ）。UIの起動はブロックしない。
  _initMonetization();

  // 前回プレイしたレベルを起動前に読み込み、初期選択として注入する。
  // チラつき（レベル0→保存値の切り替え）を避けるため runApp 前に確定させる。
  // 未保存・読込失敗時は restoreLevel 内でレベル0にフォールバックする。
  final initialLevel = await GameLevelNotifier.restoreLevel();

  runApp(ProviderScope(
    overrides: [
      gameLevelProvider
          .overrideWith((ref) => GameLevelNotifier(initialLevel)),
    ],
    child: const StartUp(),
  ));
}

/// プレミアム状態の確定 → （非プレミアムなら）広告の準備、の順で初期化する。
///
/// プレミアム会員には広告を一切出さないため、AdMob の初期化自体を行わない。
Future<void> _initMonetization() async {
  // 先にプレミアム（広告非表示サブスク）の状態を確定させる。
  // キャッシュ済みの権利を即時反映し、ストアから購入状態を復元する。
  await PremiumService.instance.init();

  if (!adsSupported) return;
  // プレミアム会員には広告を出さないので、AdMob の初期化・事前読込はしない。
  if (PremiumService.instance.isPremium.value) return;

  // GDPR 等の同意を取得（必要時のみ同意フォームを表示）。
  await ConsentManager.gatherConsent();
  // 同意が得られていない地域（UMP の canRequestAds==false）では広告をリクエストしない。
  // フォームエラー・同意拒否時はここで打ち切り、初期化も markReady() も行わない。
  // （markReady() を呼ばないため、バナー／App Open の load は AdsBootstrap.ready を
  //  待ったまま起動せず、広告リクエストが発生しない＝GDPR/AdMob ポリシー順守。）
  if (!await ConsentManager.canRequestAds()) return;
  // AdMob SDK の初期化。
  await MobileAds.instance.initialize();
  // バナー等の広告ウィジェットに「ロード開始してよい」と通知する。
  AdsBootstrap.markReady();
  // 最初のインタースティシャル・App Open を事前読込しておく。
  InterstitialAdManager.instance.preload();
  AppOpenAdManager.instance.preload();
}

class StartUp extends StatefulWidget {
  const StartUp({super.key});

  @override
  State<StartUp> createState() => _StartUpState();
}

class _StartUpState extends State<StartUp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 起動時に再エンゲージ通知を予約し直す。
    _refreshReengagementNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 直近で実際にバックグラウンドへ落ちたか（一時的な inactive と区別する）。
  // 購入シート・ストアレビュー依頼・権限/同意ダイアログ・外部ブラウザ等は inactive
  // 止まりのことがあり、そこから戻っただけで App Open を出すと意図しない割り込みに
  // なる。paused/hidden を経たときだけ「本当に復帰した」とみなす目印にする。
  bool _wentToBackground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wentToBackground = true;
    }
    // アプリを開く（前面に戻る）たびに予約をリセットし、未来へずらし直す。
    // これにより「開き続けている間は発火せず、しばらく起動がないと通知が出る」
    // という挙動になる。
    if (state == AppLifecycleState.resumed) {
      _refreshReengagementNotifications();
      // 本当にバックグラウンドから復帰したときだけ、条件を満たせば App Open 広告を出す。
      // （頻度制御・新規ユーザー猶予・他広告との連続表示防止は AppOpenAdManager 側）
      if (_wentToBackground) {
        _wentToBackground = false;
        AppOpenAdManager.instance.maybeShowOnResume();
      }
    }
  }

  Future<void> _refreshReengagementNotifications() async {
    await NotificationService.instance.init();
    final lang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    await NotificationService.instance.rescheduleReengagement(lang);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: DefColor.lightBeige,
        // アプリ全体を丸ゴシック（Zen Maru Gothic）に統一する。
        // 個々のスタイルは fontFamily を持たないため、ここで指定すれば波及する。
        fontFamily: AppText.fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: DefColor.orange,
          primary: DefColor.orange,
          secondary: DefColor.darkBlue,
          surface: DefColor.surface,
          brightness: Brightness.light,
        ),
        // タップ時の波紋は使わず、凹む立体ボタンで押下を表現する。
        splashFactory: NoSplash.splashFactory,
        highlightColor: DefColor.none,
        // 標準文字色を高コントラストの暖色ダークに統一する。
        textTheme: ThemeData.light().textTheme.apply(
              fontFamily: AppText.fontFamily,
              bodyColor: DefColor.textBlack,
              displayColor: DefColor.textBlack,
            ),
      ),
      home: const HomeView(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
