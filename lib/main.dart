import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_game/constant/ad_constant.dart';
import 'package:memory_game/services/admob.dart';
import 'package:memory_game/services/consent_manager.dart';
import 'package:memory_game/view/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 画面の向きを固定.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 広告の準備（対応プラットフォームのみ）。UIの起動はブロックしない。
  _initAds();

  runApp(const ProviderScope(child: StartUp()));
}

/// 同意取得 → AdMob初期化 → インタースティシャル事前読込 の順で広告を準備する。
Future<void> _initAds() async {
  if (!adsSupported) return;
  // GDPR 等の同意を取得（必要時のみ同意フォームを表示）。
  await ConsentManager.gatherConsent();
  // AdMob SDK の初期化。
  await MobileAds.instance.initialize();
  // 最初のインタースティシャルを事前読込しておく。
  InterstitialAdManager.instance.preload();
}

class StartUp extends StatelessWidget {
  const StartUp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: DefColor.lightBeige,
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
