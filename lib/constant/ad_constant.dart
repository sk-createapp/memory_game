import 'dart:io';

import 'package:flutter/foundation.dart';

/// 広告がサポートされているプラットフォームか（Android / iOS のみ）。
///
/// web・macOS など AdMob 非対応のプラットフォームでは広告の初期化・ロードを行わない。
bool get adsSupported {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

/// 広告ユニットIDの一元管理。
///
/// debug ビルドでは Google 公式テストID、release ビルドでは本番IDを返す。
/// （debug で本番IDを叩くと不正トラフィックとみなされるため、自動で切り替える）
class AdUnitId {
  const AdUnitId._();

  // ── Google 公式テストID（debug ビルドで使用）──
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  // ── 本番ID（release ビルドで使用）──
  // iOS: App ID = ca-app-pub-8385267635438802~9883058597（写真記憶 / Info.plist に設定）。
  static const _prodBannerIos = 'ca-app-pub-8385267635438802/7962372188';
  static const _prodInterstitialIos =
      'ca-app-pub-8385267635438802/7681390914';

  // Android: 現状未対応。AdMob で Android 用アプリ／広告ユニットを作成したら置換すること。
  // TODO: Android 本番IDに置換（App ID も AndroidManifest.xml に別途設定が必要）。
  static const _prodBannerAndroid = 'ca-app-pub-8385267635438802/0000000000';
  static const _prodInterstitialAndroid =
      'ca-app-pub-8385267635438802/0000000000';

  /// バナー広告ユニットID。非対応プラットフォームでは空文字を返す。
  static String get banner {
    if (!adsSupported) return '';
    if (Platform.isAndroid) {
      return kDebugMode ? _testBannerAndroid : _prodBannerAndroid;
    }
    return kDebugMode ? _testBannerIos : _prodBannerIos;
  }

  /// インタースティシャル広告ユニットID。非対応プラットフォームでは空文字を返す。
  static String get interstitial {
    if (!adsSupported) return '';
    if (Platform.isAndroid) {
      return kDebugMode ? _testInterstitialAndroid : _prodInterstitialAndroid;
    }
    return kDebugMode ? _testInterstitialIos : _prodInterstitialIos;
  }
}
