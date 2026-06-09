import 'dart:math';

import 'package:memory_game/constant/image_path.dart';
import 'package:memory_game/model/item_table_info.dart';
import 'package:memory_game/model/level_infos.dart';

//選択肢を生成し取得
List<String> getItemChoices(
  int num,
  List<TableItem> tableItems,
  List<String> icons, {
  Random? random,
}) {
  final answerIcons = tableItems
      .where((item) => item.isAnswerItem && item.icon != null)
      .map((item) => item.icon!)
      .toSet()
      .toList();
  final distractors = icons
      .where((icon) => !answerIcons.contains(icon))
      .toList()
    ..shuffle(random);

  final distractorNum = num - answerIcons.length;
  if (distractorNum < 0 || distractorNum > distractors.length) {
    throw ArgumentError.value(num, 'num', 'Invalid choice count.');
  }

  return [
    ...distractors.take(distractorNum),
    ...answerIcons,
  ]..shuffle(random);
}

//全問正解かを返す
bool isAllCorrect(List<TableItem> tableItems, int answerNum) {
  return tableItems
          .where((item) => item.isAnswerItem && item.answeredIcon == item.icon)
          .length ==
      answerNum;
}

bool isCompletedAnswer(ItemTableInfo itemTableInfo) =>
    itemTableInfo.isAnswerComplete;

int getLockedLevel(List<LevelInfo> levelInfos) {
  final lockedLevel = levelInfos.indexWhere((levelInfo) => levelInfo.isLocked);
  return lockedLevel == -1 ? levelInfos.length + 1 : lockedLevel;
}

//ランク（最高クリアレベル）を取得
//クリアレベルなし：-1
int getRank(List<LevelInfo> levelInfos) {
  final lastLevelIndex = min(defLevelImages.length, levelInfos.length) - 1;
  for (int i = lastLevelIndex; i >= 0; i--) {
    if (levelInfos[i].recordInfos.isNotEmpty) return i;
  }
  return -1;
}

String getFormattedTime(Duration time) {
  final minutes = time.inMinutes.toString().padLeft(2, '0');
  final seconds = (time.inSeconds % 60).toString().padLeft(2, '0');
  final centiseconds =
      ((time.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
  return '$minutes:$seconds.$centiseconds';
}
