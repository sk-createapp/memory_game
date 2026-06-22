import 'package:in_app_review/in_app_review.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ストアの星評価（レビュー）依頼を「最も高評価をつけたくなる瞬間」に出すサービス。
///
/// ネイティブのレビュー依頼（iOS: SKStoreReviewController / Android: In-App Review API）は、
/// 達成感のピークかつアプリを気に入っているユーザーに 1 回だけ出すのが鉄則。
/// このアプリでは「自己ベスト更新（新記録）」が達成感の最高潮（紙吹雪・ハプティクスが
/// 最も盛り上がる瞬間）にあたるため、そこを狙って依頼する。
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

  // 同じ端末へ繰り返し出してうるさく感じさせないための最小間隔。
  static const Duration _minInterval = Duration(days: 90);

  // 生涯で依頼する最大回数（OS 側も年内の表示回数を制限するため控えめに）。
  static const int _maxRequests = 3;

  /// 達成感のピーク（新記録）に到達したとき、条件を満たせばレビュー依頼を出す。
  ///
  /// [isNewRecord] 今回が自己ベスト更新か。false なら何もしない。
  /// [clearNum]    全期間の累計クリア回数（遊び込み度の指標）。
  Future<void> maybeRequestReviewOnAchievement({
    required bool isNewRecord,
    required int clearNum,
  }) async {
    // 達成感のピークでなければ出さない。
    if (!isNewRecord) return;
    // 遊び込んでいない（=評価が定まっていない）ユーザーには出さない。
    if (clearNum < _minClearNum) return;

    // 端末がレビュー依頼に対応していない（web・一部環境）なら何もしない。
    if (!await _inAppReview.isAvailable()) return;

    final prefs = await SharedPreferences.getInstance();

    // 生涯の依頼回数上限を超えていたら出さない。
    final count = prefs.getInt(SpKey.reviewRequestCount.name) ?? 0;
    if (count >= _maxRequests) return;

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
