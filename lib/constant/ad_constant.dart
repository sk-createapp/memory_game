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
  static const _testAppOpenAndroid = 'ca-app-pub-3940256099942544/9257395921';
  static const _testAppOpenIos = 'ca-app-pub-3940256099942544/5575463023';

  // ── 本番ID（release ビルドで使用）──
  // iOS: App ID = ca-app-pub-8385267635438802~9883058597（写真記憶 / Info.plist に設定）。
  static const _prodBannerIos = 'ca-app-pub-8385267635438802/7962372188';
  static const _prodInterstitialIos =
      'ca-app-pub-8385267635438802/7681390914';

  // App Open（アプリ起動/復帰時の全画面広告）本番ID。
  // iOS は作成済み。Android は公開予定が未定のため未作成（getter の release 分岐は
  // 空文字を返し、admob.dart 側のガードでロード・表示をスキップする＝無効リクエスト防止）。
  static const _prodAppOpenIos = 'ca-app-pub-8385267635438802/5191777183';

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

  /// App Open（アプリ復帰時の全画面）広告ユニットID。非対応プラットフォームでは空文字を返す。
  ///
  /// 本番IDが未設定（空文字）のプラットフォームでは、admob.dart 側のガードで
  /// ロード・表示をスキップする（プレースホルダIDによる無効リクエストを避ける）。
  static String get appOpen {
    if (!adsSupported) return '';
    if (Platform.isAndroid) {
      // TODO: Android 本番 App Open IDを作成したら release 側に設定する。
      return kDebugMode ? _testAppOpenAndroid : '';
    }
    return kDebugMode ? _testAppOpenIos : _prodAppOpenIos;
  }
}
