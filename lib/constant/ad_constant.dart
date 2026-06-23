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

  // Android: 本番広告ユニット未作成。AdMob で Android 用アプリ／広告ユニットを
  // 作成したら、下記 getter の release 分岐に本番IDを設定すること。
  // それまでは release で空文字を返し、admob.dart 側のガードでロードをスキップする
  // （プレースホルダIDを叩いて無効リクエスト／No-Fill を起こさないため）。

  /// バナー広告ユニットID。非対応プラットフォームでは空文字を返す。
  static String get banner {
    if (!adsSupported) return '';
    if (Platform.isAndroid) {
      // TODO: Android 本番バナーIDを作成したら release 側に設定する。
      return kDebugMode ? _testBannerAndroid : '';
    }
    return kDebugMode ? _testBannerIos : _prodBannerIos;
  }

  /// インタースティシャル広告ユニットID。非対応プラットフォームでは空文字を返す。
  static String get interstitial {
    if (!adsSupported) return '';
    if (Platform.isAndroid) {
      // TODO: Android 本番インタースティシャルIDを作成したら release 側に設定する。
      return kDebugMode ? _testInterstitialAndroid : '';
    }
    return kDebugMode ? _testInterstitialIos : _prodInterstitialIos;
  }
}
