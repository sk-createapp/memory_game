import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/model/activity_log.dart';

void main() {
  group('ActivityLog.recordPlay', () {
    test('プレイ数を増やし、クリア回数を加算する（レベルを問わない）', () {
      final day = DateTime(2026, 6, 21);
      var log = const ActivityLog();

      // 未クリアのプレイ：プレイ数のみ増える。
      log = log.recordPlay(day);
      // クリア。
      log = log.recordPlay(day, cleared: true);
      // クリア。
      log = log.recordPlay(day, cleared: true);

      final activity = log.dayOf(day);
      expect(activity.plays, 3);
      expect(activity.clears, 2);
      expect(log.isActive(day), isTrue);
      expect(log.totalClears, 2);
      expect(log.activeDayCount, 1);
    });
  });

  group('ActivityLog.currentStreak', () {
    test('当日まで連続して活動していれば日数を数える', () {
      final today = DateTime(2026, 6, 21);
      var log = const ActivityLog();
      for (var i = 0; i < 3; i++) {
        log = log.recordPlay(today.subtract(Duration(days: i)), cleared: true);
      }
      expect(log.currentStreak(today), 3);
    });

    test('当日が未活動でも、前日までの連続は途切れさせない', () {
      final today = DateTime(2026, 6, 21);
      var log = const ActivityLog();
      // 昨日・一昨日は活動、今日はまだ。
      log = log.recordPlay(today.subtract(const Duration(days: 1)),
          cleared: true);
      log = log.recordPlay(today.subtract(const Duration(days: 2)),
          cleared: true);
      expect(log.currentStreak(today), 2);
    });

    test('間が空いていれば連続は途切れる', () {
      final today = DateTime(2026, 6, 21);
      var log = const ActivityLog();
      log = log.recordPlay(today, cleared: true);
      // 2日前（昨日は空き）。
      log = log.recordPlay(today.subtract(const Duration(days: 2)),
          cleared: true);
      expect(log.currentStreak(today), 1);
    });
  });

  test('JSON へ往復しても内容が保たれる', () {
    final day = DateTime(2026, 6, 21);
    final log = const ActivityLog().recordPlay(day, cleared: true);
    final restored = ActivityLog.fromJson(log.toJson());
    expect(restored.dayOf(day).plays, 1);
    expect(restored.dayOf(day).clears, 1);
  });

  test('旧データ（clearedLevelSum）からクリア実績を引き継ぐ', () {
    final restored = ActivityLog.fromJson({
      '2026-06-21': {'plays': 2, 'clearedLevelSum': 8},
      '2026-06-20': {'plays': 1, 'clearedLevelSum': 0},
    });
    // クリア実績がある日は最低1回として移行。
    expect(restored.dayOf(DateTime(2026, 6, 21)).clears, 1);
    expect(restored.dayOf(DateTime(2026, 6, 20)).clears, 0);
  });
}
