import 'package:flutter_riverpod/legacy.dart';
import 'package:memory_game/domain/screenshot_seed.dart';
import 'package:memory_game/model/activity_log.dart';

// 継続記録（日付別の活動ログ）の管理
final activityLogProvider =
    StateNotifierProvider<ActivityLogNotifier, ActivityLog>((ref) {
  return ActivityLogNotifier();
});

class ActivityLogNotifier extends StateNotifier<ActivityLog> {
  ActivityLogNotifier() : super(const ActivityLog()) {
    _load();
  }

  Future<void> _load() async {
    // スクショ用の一時シード（撮影後は screenshot_seed.dart ごと戻す）。
    if (kScreenshotSeed) {
      state = buildSeedActivityLog(DateTime.now());
      return;
    }
    state = await ActivityLog.load();
  }

  /// 1プレイぶんの活動を今日の記録に追加する。
  /// [cleared] はそのプレイをクリアしたか（レベルを問わない）。
  void recordPlay({bool cleared = false}) {
    state = state.recordPlay(DateTime.now(), cleared: cleared);
    ActivityLog.save(state);
  }
}
