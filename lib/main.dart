import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_game/view/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 画面の向きを固定.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  //Admob広告初期化
  MobileAds.instance.initialize();
  runApp(const ProviderScope(child: StartUp()));
}

class StartUp extends StatelessWidget {
  const StartUp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomeView(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
