import 'dart:io';

import 'package:flutter/foundation.dart';

/// アプリ内課金（プレミアム＝広告非表示サブスク）がサポートされる
/// プラットフォームか（Android / iOS のみ）。
///
/// web・macOS など RevenueCat（purchases_flutter）非対応のプラットフォームでは
/// 課金導線（ペイウォール・プレミアムボタン）を出さない。
bool get iapSupported {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

/// プレミアム課金まわりの定数（RevenueCat 構成）。
///
/// セットアップ手順:
///  1. App Store Connect / Google Play Console で月額（¥200）の自動更新
///     サブスク商品（例: 商品ID `premium_monthly`）を作成する。
///  2. RevenueCat ダッシュボードで上記商品を取り込み、エンタイトルメント
///     [entitlementId]（"premium"）に紐づける。
///  3. その商品を含む Offering（current）を作成し、Monthly パッケージに割り当てる。
///  4. ダッシュボード > Project settings > API keys の「公開（public）SDK キー」を
///     プラットフォーム別に [_appleApiKey] / [_googleApiKey] へ設定する。
class Premium {
  const Premium._();

  /// RevenueCat のエンタイトルメント識別子。
  /// サブスクが有効な間だけ active になり、解約・期限切れで自動的に外れる。
  /// （meal-plan と同じ "premium" を採用）
  static const String entitlementId = 'premium';

  /// RevenueCat の公開（public）SDK キー。
  ///
  /// 公開キーはクライアントに埋め込む前提の安全なキーで、秘密鍵ではない。
  /// Apple は "appl_"、Google は "goog_" で始まる。空のままだと課金機能を
  /// 無効化し（クラッシュさせず）、キャッシュ済みの権利だけで動作する。
  ///
  /// 直接ここに書いても、ビルド時に `--dart-define` で渡してもよい
  /// （リポジトリにキーを含めたくない場合は dart-define が便利）。
  static const String _appleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_API_KEY',
    // RevenueCat「MemoryGame」プロジェクトの App Store 公開SDKキー。
    // 公開キーはクライアント埋め込み前提の安全なキー（秘密鍵ではない）。
    defaultValue: 'appl_BguxOUGyZyPsgdbJgPQRdROceNx',
  );
  static const String _googleApiKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_API_KEY',
    defaultValue: '', // 例: 'goog_xxxxxxxxxxxxxxxxxxxxxxxx'
  );

  /// 現在のプラットフォームに対応する RevenueCat 公開 SDK キー。
  /// 未対応・未設定なら空文字を返す（呼び出し側で課金機能を無効化する）。
  static String get revenueCatApiKey {
    if (kIsWeb) return '';
    if (Platform.isIOS) return _appleApiKey;
    if (Platform.isAndroid) return _googleApiKey;
    return '';
  }

  /// ストアから価格を取得できなかった場合に表示するフォールバック価格。
  /// （通常は Offering の月額パッケージの priceString を使う）
  static const String fallbackPrice = '¥200';
}
