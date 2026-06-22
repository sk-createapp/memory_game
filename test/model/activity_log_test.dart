import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/model/activity_log.dart';

void main() {
  group('ActivityLog.recordPlay', () {
    test('プレイ数を増やし、クリアレベルを合計に加算する', () {
      final day = DateTime(2026, 6, 21);
      var log = const ActivityLog();

      // 未クリアのプレイ：プレイ数のみ増える。
      log = log.recordPlay(day);
      // レベル3クリア。
      log = log.recordPlay(day, clearedLevel: 3);
      // レベル5クリア。
      log = log.recordPlay(day, clearedLevel: 5);

      final activity = log.dayOf(day);
      expect(activity.plays, 3);
      expect(activity.clearedLevelSum, 8); // 3 + 5
      expect(log.isActive(day), isTrue);
      expect(log.totalClearedLevelSum, 8);
      expect(log.activeDayCount, 1);
    });
  });

  group('ActivityLog.currentStreak', () {
    test('当日まで連続して活動していれば日数を数える', () {
      final today = DateTime(2026, 6, 21);
      var log = const ActivityLog();
      for (var i = 0; i < 3; i++) {
        log = log.recordPlay(today.subtract(Duration(days: i)),
            clearedLevel: 1);
      }
      expect(log.currentStreak(today), 3);
    });

    test('当日が未活動でも、前日までの連続は途切れさせない', () {
      final today = DateTime(2026, 6, 21);
      var log = const ActivityLog();
      // 昨日・一昨日は活動、今日はまだ。
      log = log.recordPlay(today.subtract(const Duration(days: 1)),
          clearedLevel: 1);
      log = log.recordPlay(today.subtract(const Duration(days: 2)),
          clearedLevel: 1);
      expect(log.currentStreak(today), 2);
    });

    test('間が空いていれば連続は途切れる', () {
      final today = DateTime(2026, 6, 21);
      var log = const ActivityLog();
      log = log.recordPlay(today, clearedLevel: 1);
      // 2日前（昨日は空き）。
      log = log.recordPlay(today.subtract(const Duration(days: 2)),
          clearedLevel: 1);
      expect(log.currentStreak(today), 1);
    });
  });

  test('JSON へ往復しても内容が保たれる', () {
    final day = DateTime(2026, 6, 21);
    final log = const ActivityLog().recordPlay(day, clearedLevel: 4);
    final restored = ActivityLog.fromJson(log.toJson());
    expect(restored.dayOf(day).plays, 1);
    expect(restored.dayOf(day).clearedLevelSum, 4);
  });
}
