import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_game/constant/ad_constant.dart';
import 'package:memory_game/model/activity_log.dart';
import 'package:memory_game/services/premium_service.dart';

/// 全画面広告（インタースティシャル／App Open）の表示状態を一元管理する調停役。
///
/// インタースティシャル直後にアプリへ戻った瞬間 App Open が連発する、といった
/// 「全画面広告の重複・連続表示」を防ぐ。どの全画面広告も表示の直前に
/// [markShown]、閉じたら [markClosed] を呼び、App Open 側は [isQuietFor] で
/// 「直近に全画面広告を出していないか」を確認してから表示する。
class FullScreenAdGate {
  FullScreenAdGate._();
  static final FullScreenAdGate instance = FullScreenAdGate._();

  /// 全画面広告どうしを連続表示しないための最小間隔。
  /// インタースティシャル／App Open のいずれも、直前の全画面広告からこの時間が
  /// 空くまでは出さない（例: App Open を閉じた直後にインタースティシャルが続く連発を防ぐ）。
  static const Duration backToBackGuard = Duration(seconds: 30);

  /// いずれかの全画面広告が今まさに表示中か。
  bool isShowing = false;

  /// 直近に全画面広告を表示／終了した時刻（表示開始時と終了時の両方で更新）。
  /// 連続表示ガードはこの時刻からの経過で測る。
  DateTime? _lastShownAt;

  /// 全画面広告を表示し始めたことを記録する。
  void markShown() {
    isShowing = true;
    _lastShownAt = DateTime.now();
  }

  /// 全画面広告を閉じたことを記録する。
  ///
  /// 連続表示ガード（[isQuietFor]）は「広告を閉じてから」の経過で測りたいので、
  /// 閉じた時刻でも [_lastShownAt] を更新する。これがないと、長尺（>ガード時間）の
  /// 広告を閉じた直後に次の全画面広告が出てしまう（表示開始時刻基準だと既に経過済みのため）。
  void markClosed() {
    isShowing = false;
    _lastShownAt = DateTime.now();
  }

  /// 直近 [gap] の間、全画面広告を出していない（かつ表示中でもない）か。
  bool isQuietFor(Duration gap) {
    if (isShowing) return false;
    final last = _lastShownAt;
    return last == null || DateTime.now().difference(last) >= gap;
  }
}

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

  // ── ロード失敗時のリトライ制御 ──
  /// リトライ回数の上限（これを超えたら領域を畳んで諦める）。
  static const int _maxRetries = 3;

  /// リトライまでの待機時間。
  static const Duration _retryDelay = Duration(seconds: 5);

  int _retryCount = 0;
  bool _loadFailed = false;
  Timer? _retryTimer;

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
          if (!mounted) return;
          _bannerAd = null;
          // 一時的な失敗（在庫なし・起動直後の通信瞬断など）に備えて、
          // 上限付きで一定時間後に再ロードする。
          if (_retryCount < _maxRetries) {
            _retryCount++;
            _retryTimer?.cancel();
            _retryTimer = Timer(_retryDelay, () {
              if (!mounted) return;
              _loadAd();
            });
          } else {
            // 上限到達。空の予約領域を残さないよう畳む。
            setState(() => _loadFailed = true);
          }
        },
      ),
    );
    banner.load();
    _bannerAd = banner;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
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
        // リトライ上限まで失敗したら、空の予約領域を残さず畳む。
        // 広告ユニットID未設定（Android release 未作成・非対応プラットフォーム）でも、
        // ロード自体が始まらず畳むパスに乗らないため、ここで空の予約領域を残さない。
        if (_loadFailed || AdUnitId.banner.isEmpty) {
          return const SizedBox.shrink();
        }
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

  /// この生涯プレイ回数に達するまではインタースティシャルを出さない（新規ユーザー保護）。
  ///
  /// 「アプリを残すか消すか」を決めている遊び始めの体験を広告で妨げないことで、
  /// 初日のリテンションを守る。十分に遊び込んでから（=定着しはじめてから）回収する。
  static const int _minTotalPlaysBeforeShow = 3;

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
  /// [totalPlays] は全期間の総プレイ回数。遊び始めの新規ユーザーには出さず、
  /// 十分に遊び込んでから回収する（リテンション保護）。
  /// 表示の有無にかかわらず、最終的に [onDone] を必ず呼ぶ（画面遷移を止めない）。
  void maybeShow({required int totalPlays, required VoidCallback onDone}) {
    // プレミアム会員には広告を出さず、そのまま画面遷移する。
    if (PremiumService.instance.isPremium.value) {
      onDone();
      return;
    }

    _gameOverCount++;

    final ad = _ad;
    if (ad == null || !_shouldShow(totalPlays)) {
      // 表示しない場合も次回に備えて読み込んでおく。
      preload();
      onDone();
      return;
    }

    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        FullScreenAdGate.instance.markClosed();
        ad.dispose();
        preload();
        onDone();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        FullScreenAdGate.instance.markClosed();
        ad.dispose();
        preload();
        onDone();
      },
    );
    // 表示を確定する直前に調停役へ予約する。showed コールバックを待つと、その間に
    // 別の全画面広告（App Open 等）が割り込めてしまうため、show 直前に立てる。
    FullScreenAdGate.instance.markShown();
    _lastShownAt = DateTime.now();
    ad.show();
  }

  /// 頻度制御の条件を満たすか（新規ユーザー猶予・回数・最小間隔・他広告との連続防止）。
  bool _shouldShow(int totalPlays) {
    // 遊び始めの新規ユーザーには出さない（初日リテンションの保護）。
    if (totalPlays < _minTotalPlaysBeforeShow) return false;
    if (_gameOverCount % _showEveryNGames != 0) return false;
    final last = _lastShownAt;
    if (last != null && DateTime.now().difference(last) < _minInterval) {
      return false;
    }
    // App Open 等の全画面広告を出した直後は連発を避ける。
    // （例: 復帰時の App Open を閉じてからホームへ戻った場合）
    if (!FullScreenAdGate.instance.isQuietFor(FullScreenAdGate.backToBackGuard)) {
      return false;
    }
    return true;
  }
}

/// App Open（アプリ復帰時の全画面）広告の事前読込・頻度制御付き表示を管理する。
///
/// バックグラウンドから復帰したタイミング（=新しいセッションの開始）で表示する、
/// eCPM の高い全画面広告。リテンション保護のため次のガードを全て満たすときだけ出す:
/// プレミアム除外／本番ID設定済み／新規ユーザー猶予（[_minTotalPlays]）／
/// 前回表示からの最小間隔（[_minInterval]）／直前に他の全画面広告を出していない。
class AppOpenAdManager {
  AppOpenAdManager._();
  static final AppOpenAdManager instance = AppOpenAdManager._();

  // ── 頻度制御パラメータ ──
  /// この生涯プレイ回数に達するまでは App Open を出さない（新規ユーザー保護）。
  /// 遊び始めの体験を起動広告で妨げないことで初日リテンションを守る。
  static const int _minTotalPlays = 4;

  /// 前回 App Open を表示してからの最小間隔（控えめな表示頻度に保つ）。
  static const Duration _minInterval = Duration(minutes: 15);

  /// App Open 広告の有効期限（Google 仕様: ロードから4時間で失効）。
  static const Duration _expiry = Duration(hours: 4);

  AppOpenAd? _ad;
  bool _isLoading = false;
  DateTime? _loadedAt;
  DateTime? _lastShownAt;

  /// App Open 広告を事前読込する。すでに保持中／読込中なら何もしない。
  ///
  /// 復帰(resume)経由でも呼ばれるため、SDK初期化＆同意取得の完了（[AdsBootstrap.ready]）を
  /// 待ってから load する（バナーと同様。未初期化・同意前の load 要求を防ぐ）。
  Future<void> preload() async {
    if (!adsSupported || _isLoading || _ad != null) return;
    // プレミアム会員には広告を出さないので事前読込もしない。
    if (PremiumService.instance.isPremium.value) return;
    final adUnitId = AdUnitId.appOpen;
    if (adUnitId.isEmpty) return;

    // 二重ロードを防ぐため、待機に入る前にフラグを立てる。
    _isLoading = true;
    // SDK初期化＆同意取得が完了するまで待つ（未初期化での load 失敗を防ぐ）。
    // adsSupported かつ非プレミアムのときは _initMonetization が markReady() に到達するため、
    // この Future は必ず解決する（プレミアム・非対応は上のガードで既に return 済み）。
    await AdsBootstrap.ready;
    // 待機中にプレミアム化していたら読み込まない。
    if (PremiumService.instance.isPremium.value) {
      _isLoading = false;
      return;
    }

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loadedAt = DateTime.now();
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// 読み込み済みの広告が失効しているか（ロードから [_expiry] 経過）。
  bool get _isExpired {
    final loadedAt = _loadedAt;
    return loadedAt == null ||
        DateTime.now().difference(loadedAt) >= _expiry;
  }

  /// 表示条件を満たせば App Open 広告を表示する（バックグラウンド復帰時に呼ぶ）。
  ///
  /// 条件を満たさない・広告が未読込のときは何もせず、次回に備えて事前読込する。
  Future<void> maybeShowOnResume() async {
    if (!adsSupported) return;
    // プレミアム会員には出さない。
    if (PremiumService.instance.isPremium.value) return;
    if (AdUnitId.appOpen.isEmpty) return;

    // 直前に他の全画面広告（インタースティシャル等）を出していたら出さない。
    // インタースティシャルを閉じた直後の復帰で連発するのを防ぐ。
    if (!FullScreenAdGate.instance.isQuietFor(FullScreenAdGate.backToBackGuard)) {
      return;
    }

    // 前回 App Open からの最小間隔を空ける（控えめな頻度）。
    final lastShown = _lastShownAt;
    if (lastShown != null &&
        DateTime.now().difference(lastShown) < _minInterval) {
      return;
    }

    // 広告が未読込／失効していれば、表示せず読み込み直して次回に備える。
    final ad = _ad;
    if (ad == null || _isExpired) {
      if (_isExpired) {
        _ad?.dispose();
        _ad = null;
        _loadedAt = null;
      }
      preload();
      return;
    }

    // 遊び始めの新規ユーザーには出さない（初日リテンションの保護）。
    // 生涯プレイ回数は永続化済みの活動ログから読む。
    final log = await ActivityLog.load();
    if (log.totalPlays < _minTotalPlays) return;

    // 待機(await)中に状態が変わっていないか再確認する（プレミアム化／再びバックグラウンド化／
    // 他の全画面広告が表示〜終了して連続表示ガード窓に入った／広告が差し替わった／失効した）。
    if (PremiumService.instance.isPremium.value) return;
    // await 中にアプリが再びバックグラウンドへ落ちていたら表示しない（前面復帰中のみ出す）。
    // バックグラウンドで show() すると失敗し、ゲートを無駄に消費するため。
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    if (!FullScreenAdGate.instance.isQuietFor(FullScreenAdGate.backToBackGuard)) {
      return;
    }
    if (_ad != ad) return;
    // await が失効境界（4時間）をまたいだ場合は、失効済み広告を出さず読み込み直す。
    if (_isExpired) {
      ad.dispose();
      _ad = null;
      _loadedAt = null;
      preload();
      return;
    }

    _ad = null;
    _loadedAt = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        // 実際に表示できたときだけ頻度上限（最小間隔）を消費する。
        // show 失敗時に消費すると、出していないのに15分間ブロックされてしまうため。
        _lastShownAt = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        FullScreenAdGate.instance.markClosed();
        ad.dispose();
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        FullScreenAdGate.instance.markClosed();
        ad.dispose();
        preload();
      },
    );
    // 表示を確定する直前に調停役へ予約する（isQuietFor 通過〜showed の隙間に別の
    // 全画面広告が割り込むのを防ぐ）。show 失敗時は onAdFailedToShow で markClosed する。
    FullScreenAdGate.instance.markShown();
    ad.show();
  }
}
