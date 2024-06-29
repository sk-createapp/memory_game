import 'dart:io';

class AdMobService {
  String getBannerAdUnitId() {
    // iOSとAndroidで広告ユニットIDを分岐させる
    if (Platform.isAndroid) {
      //TODO テスト用IDなので正式なIDに置換
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // iOSの広告ユニットID
      return "";
    }
    return "";
  }
}
