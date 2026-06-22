import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review_platform_interface/in_app_review_platform_interface.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:memory_game/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// レビュー依頼の出し時を制御する [ReviewService] の判定ロジックを検証する。
///
/// ネイティブ依頼は OS が制御し結果が返らないため、ここでは
/// 「requestReview を呼んだ／呼んでいない」と SharedPreferences の更新で判定する。
class _FakeInAppReview extends InAppReviewPlatform {
  _FakeInAppReview({this.available = true});

  final bool available;
  int requestReviewCallCount = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {
    requestReviewCallCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeInAppReview fake;

  setUp(() {
    fake = _FakeInAppReview();
    InAppReviewPlatform.instance = fake;
    SharedPreferences.setMockInitialValues({});
  });

  Future<int> requestCountPref() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(SpKey.reviewRequestCount.name) ?? 0;
  }

  group('ReviewService.maybeRequestReviewOnAchievement', () {
    test('新記録かつ十分に遊び込んでいれば依頼を出し、回数を記録する', () async {
      await ReviewService.instance.maybeRequestReviewOnAchievement(
        isNewRecord: true,
        clearNum: 5,
      );

      expect(fake.requestReviewCallCount, 1);
      expect(await requestCountPref(), 1);
    });

    test('新記録でなければ達成感のピークではないので出さない', () async {
      await ReviewService.instance.maybeRequestReviewOnAchievement(
        isNewRecord: false,
        clearNum: 50,
      );

      expect(fake.requestReviewCallCount, 0);
      expect(await requestCountPref(), 0);
    });

    test('クリア回数が少ない（評価が定まらない）ユーザーには出さない', () async {
      await ReviewService.instance.maybeRequestReviewOnAchievement(
        isNewRecord: true,
        clearNum: 4,
      );

      expect(fake.requestReviewCallCount, 0);
      expect(await requestCountPref(), 0);
    });

    test('生涯の依頼回数上限に達していたら出さない', () async {
      SharedPreferences.setMockInitialValues({
        SpKey.reviewRequestCount.name: 3,
      });

      await ReviewService.instance.maybeRequestReviewOnAchievement(
        isNewRecord: true,
        clearNum: 100,
      );

      expect(fake.requestReviewCallCount, 0);
    });

    test('クールダウン中（直近に出した）なら出さない', () async {
      SharedPreferences.setMockInitialValues({
        SpKey.reviewLastRequested.name: DateTime.now().millisecondsSinceEpoch,
        SpKey.reviewRequestCount.name: 1,
      });

      await ReviewService.instance.maybeRequestReviewOnAchievement(
        isNewRecord: true,
        clearNum: 100,
      );

      expect(fake.requestReviewCallCount, 0);
    });

    test('前回依頼から十分に時間が経っていれば再び出す', () async {
      final longAgo = DateTime.now()
          .subtract(const Duration(days: 120))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        SpKey.reviewLastRequested.name: longAgo,
        SpKey.reviewRequestCount.name: 1,
      });

      await ReviewService.instance.maybeRequestReviewOnAchievement(
        isNewRecord: true,
        clearNum: 100,
      );

      expect(fake.requestReviewCallCount, 1);
      expect(await requestCountPref(), 2);
    });

    test('端末がレビュー依頼に対応していなければ出さず、記録もしない', () async {
      fake = _FakeInAppReview(available: false);
      InAppReviewPlatform.instance = fake;

      await ReviewService.instance.maybeRequestReviewOnAchievement(
        isNewRecord: true,
        clearNum: 100,
      );

      expect(fake.requestReviewCallCount, 0);
      expect(await requestCountPref(), 0);
    });
  });
}
