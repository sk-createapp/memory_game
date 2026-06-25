import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/model/activity_log.dart';
import 'package:memory_game/model/level_infos.dart';

/// スクリーンショット用の一時シード。
///
/// このフラグが `true` の間は、起動時に
///   - レベル別記録（各レベルに複数件＋育成EXP）
///   - 継続記録（当月をいい感じに埋める・連続約15日）
/// をダミーデータで「上書き」する（端末の保存データは無視される）。
///
/// ⚠️ スクショ撮影が終わったら元に戻すこと：
///   1. このフラグを `false` にする（or このファイルを削除して呼び出し箇所を戻す）
///   2. `level_infos_state.dart` / `activity_log_state.dart` のシード分岐を削除
/// 撮影中にプレイすると端末にダミー由来のデータが保存され得るので、
/// 本番に戻す際はアプリの再インストール（データ削除）が確実。
const bool kScreenshotSeed = true;

/// 各レベルに複数の記録と育成EXPを持たせたシード。全レベル解放。
List<LevelInfo> buildSeedLevelInfos(DateTime now) {
  // 育成段階に変化が出るよう、レベルごとにEXPをばらす。
  // しきい値: [0,30,90,200,400] = あかちゃん/こども/わかもの/おとな/はかせ
  const exps = <int>[
    400, 240, 150, 95, 320, 200, 110, 45, 90, 35, //
    200, 130, 60, 400, 95, 30, 160, 220, 90, 45,
  ];
  // 目標タイムに対する倍率（昇順＝ベスト順）。
  const factors = <double>[0.45, 0.6, 0.72, 0.85, 0.95, 1.08, 1.25, 1.45];

  final infos = <LevelInfo>[];
  for (var i = 0; i < DefNum.maxLevel; i++) {
    final target = 6 + i * 1.5; // levelTargetSeconds 相当（秒）
    final count = 5 + (i % 4); // 5〜8 件
    final records = <RecordInfo>[];
    for (var k = 0; k < count; k++) {
      final seconds = target * factors[k];
      final daysAgo = (i * 2 + k * 3) % 24; // 直近24日内にばらけさせる
      records.add(RecordInfo(
        memorizeTime: Duration(milliseconds: (seconds * 1000).round()),
        recordedDate: now.subtract(Duration(days: daysAgo, hours: k * 2)),
      ));
    }
    records.sort((a, b) => a.memorizeTime.compareTo(b.memorizeTime));
    infos.add(LevelInfo(
      recordInfos: List.unmodifiable(records),
      isLocked: false,
      exp: exps[i % exps.length],
    ));
  }
  return infos;
}

/// 当月（=now の月）をいい感じに埋め、連続日数15日になる継続記録のシード。
ActivityLog buildSeedActivityLog(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final days = <String, DayActivity>{};

  // 直近15日を連続させる（今日含む today..today-14）→ 連続日数 = 15。
  // ヒートマップに濃淡が出るようクリア回数を散らす（1〜12）。
  const streakClears = <int>[4, 7, 2, 11, 3, 5, 8, 1, 6, 3, 9, 2, 5, 12, 4];
  for (var i = 0; i < streakClears.length; i++) {
    final date = today.subtract(Duration(days: i));
    final c = streakClears[i];
    days[ActivityLog.dateKey(date)] = DayActivity(plays: c + 1, clears: c);
  }

  // 16日前（today-15）は意図的に休み＝連続を15日ちょうどで止める。
  // それ以前を当月内でまばらに埋める（gap あり）。値は { daysAgo: clears }。
  const older = <int, int>{
    17: 2,
    18: 5,
    20: 3,
    21: 0, // プレイのみ（クリア0）→淡色マス
    22: 4,
    24: 6,
    25: 2,
  };
  older.forEach((daysAgo, c) {
    final date = today.subtract(Duration(days: daysAgo));
    // 当月内の日付だけ埋める（月初付近で前月にはみ出さない）。
    if (date.year != now.year || date.month != now.month) return;
    days[ActivityLog.dateKey(date)] =
        DayActivity(plays: c == 0 ? 2 : c + 1, clears: c);
  });

  return ActivityLog(days: days);
}
