import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  String getBannerAdUnitId() {
    if (kIsWeb) {
      return '';
    }

    // iOSとAndroidで広告ユニットIDを分岐させる
    if (Platform.isAndroid) {
      //TODO テスト用IDなので正式なIDに置換
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      //TODO テスト用IDなので正式なIDに置換
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }
}

/// google_mobile_ads のバナー広告を読み込んで表示するウィジェット。
/// 旧 admob_flutter の `AdmobBanner` を置き換える。
class AdmobBannerWidget extends StatefulWidget {
  const AdmobBannerWidget({super.key});

  @override
  State<AdmobBannerWidget> createState() => _AdmobBannerWidgetState();
}

class _AdmobBannerWidgetState extends State<AdmobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adUnitId = AdMobService().getBannerAdUnitId();
    if (adUnitId.isEmpty) return;

    final banner = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    banner.load();
    _bannerAd = banner;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 読み込み中は同サイズの領域を確保してレイアウトのガタつきを防ぐ。
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(
        width: 320,
        height: 50,
      );
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
