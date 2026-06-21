import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// UMP（User Messaging Platform）による同意管理。
///
/// GDPR 等の対象地域では、広告をリクエストする前に同意を取得する必要がある。
/// google_mobile_ads に内蔵された UMP を利用するため、追加パッケージは不要。
class ConsentManager {
  const ConsentManager._();

  /// 同意情報を更新し、必要であれば同意フォームを表示する。
  ///
  /// エラーが発生してもアプリ起動はブロックしない（広告だけがスキップされる）。
  static Future<void> gatherConsent() async {
    final completer = Completer<void>();
    final params = ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        // 必要であれば同意フォームをロード・表示する。
        await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError != null) {
            debugPrint('UMP consent form error: ${formError.message}');
          }
          if (!completer.isCompleted) completer.complete();
        });
      },
      (error) {
        debugPrint('UMP consent info update error: ${error.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );

    return completer.future;
  }

  /// 広告をリクエストできる状態か。
  static Future<bool> canRequestAds() {
    return ConsentInformation.instance.canRequestAds();
  }
}
