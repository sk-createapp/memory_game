import 'package:flutter_riverpod/legacy.dart';
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
    state = await ActivityLog.load();
  }

  /// 1プレイぶんの活動を今日の記録に追加する。
  /// [clearedLevel] はクリアしたレベル番号（1始まり）。未クリアなら null。
  void recordPlay({int? clearedLevel}) {
    state = state.recordPlay(DateTime.now(), clearedLevel: clearedLevel);
    ActivityLog.save(state);
  }
}
