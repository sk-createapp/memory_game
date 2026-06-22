import 'dart:io';

import 'package:flutter/foundation.dart';

/// アプリ内課金（プレミアム＝広告非表示サブスク）がサポートされる
/// プラットフォームか（Android / iOS のみ）。
///
/// web・macOS など in_app_purchase 非対応のプラットフォームでは
/// 課金導線（ペイウォール・プレミアムボタン）を出さない。
bool get iapSupported {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

/// プレミアム課金まわりの定数。
class Premium {
  const Premium._();

  /// 月額プレミアムの商品ID（自動更新サブスクリプション）。
  ///
  /// App Store Connect / Google Play Console の両方で、この同一IDの
  /// 月額（¥200）サブスクリプション商品を作成する必要がある。
  static const String monthlyProductId = 'premium_monthly';

  /// ストアから価格を取得できなかった場合に表示するフォールバック価格。
  /// （通常は ProductDetails.price のローカライズ済み文字列を使う）
  static const String fallbackPrice = '¥200';
}
