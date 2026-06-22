import 'dart:convert';

import 'package:memory_game/constant/sp_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 1日ぶんの活動量。
///
/// [plays] はその日に遊んだ回数（クリア有無を問わない＝「やった日」の判定に使う）。
/// [clearedLevelSum] はその日にクリアしたレベル番号の合計
/// （例: レベル3とレベル5をクリアすると 3+5=8）。カレンダーのヒートマップ濃淡と
/// 表示数値に使う。
class DayActivity {
  final int plays;
  final int clearedLevelSum;

  const DayActivity({this.plays = 0, this.clearedLevelSum = 0});

  DayActivity copyWith({int? plays, int? clearedLevelSum}) => DayActivity(
        plays: plays ?? this.plays,
        clearedLevelSum: clearedLevelSum ?? this.clearedLevelSum,
      );

  Map<String, dynamic> toJson() => {
        'plays': plays,
        'clearedLevelSum': clearedLevelSum,
      };

  static DayActivity fromJson(Map<String, dynamic> json) => DayActivity(
        plays: (json['plays'] as num?)?.toInt() ?? 0,
        clearedLevelSum: (json['clearedLevelSum'] as num?)?.toInt() ?? 0,
      );
}

/// 継続記録（日付別の活動ログ）。
///
/// レベルごとのベストタイム（[level_infos]）は上位10件に剪定され全プレイ履歴を
/// 保持できないため、連続日数・カレンダー用に専用のログとして別管理する。
/// キーは端末ローカル日付の "yyyy-MM-dd"。
class ActivityLog {
  final Map<String, DayActivity> days;

  const ActivityLog({this.days = const {}});

  /// 日付をローカル "yyyy-MM-dd" のキーへ正規化する。
  static String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DayActivity dayOf(DateTime date) => days[dateKey(date)] ?? const DayActivity();

  /// その日に1回でも遊んだか（=「やった日」）。
  bool isActive(DateTime date) => (days[dateKey(date)]?.plays ?? 0) > 0;

  /// 全期間のクリアレベル合計（「クリアしたレベルを加算した数」の累計）。
  int get totalClearedLevelSum =>
      days.values.fold(0, (sum, d) => sum + d.clearedLevelSum);

  /// 遊んだ日数（のべ）。
  int get activeDayCount => days.values.where((d) => d.plays > 0).length;

  /// 全期間の総プレイ回数（クリア有無を問わない）。エンゲージメントの指標として
  /// ペイウォールの表示判定などに使う。
  int get totalPlays => days.values.fold(0, (sum, d) => sum + d.plays);

  /// [from]（通常は今日）を起点に、過去へさかのぼった連続活動日数。
  ///
  /// 当日まだ遊んでいない場合でも「途切れた」とはせず、前日までの連続を返す。
  /// （その日のうちに遊べばそのまま連続が伸びる挙動にする）
  int currentStreak(DateTime from) {
    var day = DateTime(from.year, from.month, from.day);
    if (!isActive(day)) {
      day = day.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (isActive(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// [date] に1プレイぶんの活動を加えた新しいログを返す。
  /// [clearedLevel] はクリアしたレベル番号（1始まり）。未クリアなら null。
  ActivityLog recordPlay(DateTime date, {int? clearedLevel}) {
    final key = dateKey(date);
    final cur = days[key] ?? const DayActivity();
    final add =
        (clearedLevel != null && clearedLevel > 0) ? clearedLevel : 0;
    final nextDays = Map<String, DayActivity>.from(days)
      ..[key] = cur.copyWith(
        plays: cur.plays + 1,
        clearedLevelSum: cur.clearedLevelSum + add,
      );
    return ActivityLog(days: nextDays);
  }

  Map<String, dynamic> toJson() =>
      days.map((k, v) => MapEntry(k, v.toJson()));

  static ActivityLog fromJson(Map<String, dynamic> json) {
    final days = <String, DayActivity>{};
    json.forEach((k, v) {
      if (v is Map) {
        days[k] = DayActivity.fromJson(v.cast<String, dynamic>());
      }
    });
    return ActivityLog(days: days);
  }

  // SP保存
  static Future<void> save(ActivityLog log) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SpKey.activityLog.name, jsonEncode(log.toJson()));
  }

  // SP取得
  static Future<ActivityLog> load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? json = prefs.getString(SpKey.activityLog.name);
      if (json == null) return const ActivityLog();
      return ActivityLog.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return const ActivityLog();
    }
  }
}
