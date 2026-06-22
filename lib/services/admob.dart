import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_game/constant/ad_constant.dart';
import 'package:memory_game/services/premium_service.dart';

/// 広告SDKの初期化＋同意取得の完了を表すゲート。
///
/// バナー等の広告ウィジェットはこの完了を待ってからロードする。
/// （未初期化のまま load すると失敗して広告が表示されないため）
class AdsBootstrap {
  AdsBootstrap._();
  static final Completer<void> _ready = Completer<void>();

  /// 初期化＋同意取得が完了すると解決される Future。
  static Future<void> get ready => _ready.future;

  /// 準備完了をマークする（複数回呼ばれても安全）。
  static void markReady() {
    if (!_ready.isCompleted) _ready.complete();
  }
}

/// google_mobile_ads のアンカー型アダプティブバナー広告を読み込んで表示するウィジェット。
///
/// 画面幅に応じて最適なバナーサイズを取得することで、固定 320x50 より収益性を高める。
class AdmobBannerWidget extends StatefulWidget {
  const AdmobBannerWidget({super.key});

  @override
  State<AdmobBannerWidget> createState() => _AdmobBannerWidgetState();
}

class _AdmobBannerWidgetState extends State<AdmobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _adSize;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 画面幅（MediaQuery）が確定してから1回だけロードする。
    if (!_loadStarted) {
      _loadStarted = true;
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    if (!adsSupported) return;
    // プレミアム会員には広告を出さないので読み込みもしない。
    if (PremiumService.instance.isPremium.value) return;
    final adUnitId = AdUnitId.banner;
    if (adUnitId.isEmpty) return;

    // SDK初期化＆同意取得が完了するまで待つ（未初期化での load 失敗を防ぐ）。
    await AdsBootstrap.ready;
    if (!mounted) return;

    // 画面幅に応じたアンカー型アダプティブバナーサイズを取得する。
    final width = MediaQuery.of(context).size.width.truncate();
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;
    setState(() => _adSize = size);

    final banner = BannerAd(
      adUnitId: adUnitId,
      size: size,
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
    // プレミアム会員には広告を出さない。購入後は即座に消えるよう購読する。
    return ValueListenableBuilder<bool>(
      valueListenable: PremiumService.instance.isPremium,
      builder: (context, isPremium, _) {
        if (isPremium) return const SizedBox.shrink();
        // 読み込み中は同サイズの領域を確保してレイアウトのガタつきを防ぐ。
        if (!_isLoaded || _bannerAd == null) {
          return SizedBox(
            width:
                _adSize?.width.toDouble() ?? MediaQuery.of(context).size.width,
            height: _adSize?.height.toDouble() ?? 60,
          );
        }
        return SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }
}

/// インタースティシャル広告の事前読込・頻度制御付き表示を管理するシングルトン。
///
/// ゲーム終了時（Result → Home 遷移）に呼び出される。頻度制御により、
/// 一定回数のゲーム完了ごと・かつ前回表示から一定時間経過後にのみ表示する。
class InterstitialAdManager {
  InterstitialAdManager._();
  static final InterstitialAdManager instance = InterstitialAdManager._();

  // ── 頻度制御パラメータ ──
  /// 何回のゲーム完了ごとに表示するか。
  static const int _showEveryNGames = 2;

  /// 前回表示からの最小間隔（連続表示の抑制）。
  static const Duration _minInterval = Duration(seconds: 60);

  InterstitialAd? _ad;
  bool _isLoading = false;
  int _gameOverCount = 0;
  DateTime? _lastShownAt;

  /// インタースティシャル広告を事前読込する。すでに保持中／読込中なら何もしない。
  void preload() {
    if (!adsSupported || _isLoading || _ad != null) return;
    // プレミアム会員には広告を出さないので事前読込もしない。
    if (PremiumService.instance.isPremium.value) return;
    final adUnitId = AdUnitId.interstitial;
    if (adUnitId.isEmpty) return;

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// 頻度制御を満たせばインタースティシャルを表示する。
  ///
  /// 表示の有無にかかわらず、最終的に [onDone] を必ず呼ぶ（画面遷移を止めない）。
  void maybeShow({required VoidCallback onDone}) {
    // プレミアム会員には広告を出さず、そのまま画面遷移する。
    if (PremiumService.instance.isPremium.value) {
      onDone();
      return;
    }

    _gameOverCount++;

    final ad = _ad;
    if (ad == null || !_shouldShow()) {
      // 表示しない場合も次回に備えて読み込んでおく。
      preload();
      onDone();
      return;
    }

    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload();
        onDone();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preload();
        onDone();
      },
    );
    _lastShownAt = DateTime.now();
    ad.show();
  }

  /// 頻度制御の条件を満たすか（回数・最小間隔）。
  bool _shouldShow() {
    if (_gameOverCount % _showEveryNGames != 0) return false;
    final last = _lastShownAt;
    if (last != null && DateTime.now().difference(last) < _minInterval) {
      return false;
    }
    return true;
  }
}
