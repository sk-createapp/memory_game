import 'package:in_app_review/in_app_review.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ストアの星評価（レビュー）依頼を「最も高評価をつけたくなる瞬間」に出すサービス。
///
/// ネイティブのレビュー依頼（iOS: SKStoreReviewController / Android: In-App Review API）は、
/// 達成感のピークかつアプリを気に入っているユーザーに出すのが鉄則。
/// このアプリでは初回を「自己ベスト更新（新記録）」という達成感の最高潮（紙吹雪・
/// ハプティクスが最も盛り上がる瞬間）に出し、2回目以降は通常のクリア直後でも出す。
/// いずれも結果画面に入った直後（＝広告が出る前）に呼び、広告直後の不快なタイミングを避ける。
///
/// Apple / Google のガイドライン上、ネイティブ依頼を独自の「好き？」プリダイアログで
/// フィルタするのは非推奨のため、条件を満たしたらそのままネイティブ依頼を呼ぶ。
/// （表示の有無・結果は OS 側が完全に制御し、本アプリには返らない）
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  final InAppReview _inAppReview = InAppReview.instance;

  // レビュー依頼を出してよいと判断する最小の累計クリア回数。
  // 初クリア直後の新規ユーザーは評価が定まっておらず低評価になりやすいので、
  // 何度か遊び込んで（＝アプリを気に入って）いる段階に限定する。
  static const int _minClearNum = 5;

  // レビュー依頼を出してよいと判断する最小のプレイ日数（複数日使っている人に限定）。
  static const int _minPlayDays = 3;

  // 同じ端末へ繰り返し出してうるさく感じさせないための最小間隔。
  static const Duration _minInterval = Duration(days: 90);

  // 生涯で依頼する最大回数（OS 側も年内の表示回数を制限するため控えめに）。
  static const int _maxRequests = 3;

  /// クリア直後（達成感のあるタイミング・広告が出る前）に、条件を満たせばレビュー
  /// 依頼を出す。初回は達成感が最高潮の「自己ベスト更新（新記録）」の瞬間に限定し、
  /// 2回目以降は通常のクリアでもよい（その頃にはアプリへの評価が定まっている）。
  ///
  /// [isNewRecord] 今回が自己ベスト更新か（初回依頼の判定に使う）。
  /// [clearNum]    全期間の累計クリア回数（遊び込み度の指標）。
  /// [playDays]    遊んだ日数（複数日使っているかの指標）。
  Future<void> maybeRequestReviewAfterClear({
    required bool isNewRecord,
    required int clearNum,
    required int playDays,
  }) async {
    // 遊び込んでいない（=評価が定まっていない）ユーザーには出さない。
    if (clearNum < _minClearNum) return;
    if (playDays < _minPlayDays) return;

    // 端末がレビュー依頼に対応していない（web・一部環境）なら何もしない。
    if (!await _inAppReview.isAvailable()) return;

    final prefs = await SharedPreferences.getInstance();

    // 生涯の依頼回数上限を超えていたら出さない。
    final count = prefs.getInt(SpKey.reviewRequestCount.name) ?? 0;
    if (count >= _maxRequests) return;

    // 初回は達成感のピーク（新記録）でのみ出す。2回目以降は通常クリアでもよい。
    if (count == 0 && !isNewRecord) return;

    // 直近に出していたら（クールダウン中なら）出さない。
    final lastMillis = prefs.getInt(SpKey.reviewLastRequested.name);
    if (lastMillis != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMillis);
      if (DateTime.now().difference(last) < _minInterval) return;
    }

    // 表示の有無は OS が返さないため、呼び出し（試行）ベースで間隔・回数を制御する。
    // 依頼を出す前に記録しておき、二重発火しても多重に出さないようにする。
    await prefs.setInt(
      SpKey.reviewLastRequested.name,
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.setInt(SpKey.reviewRequestCount.name, count + 1);

    await _inAppReview.requestReview();
  }
}
