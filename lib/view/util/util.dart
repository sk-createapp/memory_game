import 'package:memory_game/constant/image_path.dart';
import 'package:memory_game/model/item_table_info.dart';
import 'package:memory_game/model/level_infos.dart';

//選択肢を生成し取得
List<String> getItemChoices(
    int num, List<TableItem> tableItems, List<String> icons) {
  List<String> ret = [];
  List<String> ans = [];
  int answerItemNum = 0;

  ret = List.of(defImages);

  //アイコン全リストから回答対象を除外しておく
  for (var element in tableItems) {
    if (element.isAnswerItem &&
        element.icon != null &&
        ans.contains(element.icon) == false) {
      ret.remove(element.icon!);
      ans.add(element.icon!);
      answerItemNum++;
    }
  }

  //アイコン全リストを選択肢数がnumになるように減らす
  ret.shuffle();
  ret.removeRange(num - answerItemNum, ret.length);

  //回答対象を含めてシャッフル
  for (var element in ans) {
    ret.add(element);
  }
  ret.shuffle();

  return ret;
}

//全問正解かを返す
bool isAllCorrect(List<TableItem> tableItems, int answerNum) {
  return tableItems.where((element) {
        if (element.isAnswerItem && element.answeredIcon == element.icon) {
          return true;
        }
        return false;
      }).length ==
      answerNum;
}

//ランク（最高クリアレベル）を取得
//クリアレベルなし：-1
int getRank(List<LevelInfo> levelInfos) {
  int ret = -1;
  for (int i = 0; i < defLevelImages.length; i++) {
    if (levelInfos[i].recordInfos.isNotEmpty) {
      ret = i;
    }
  }
  return ret;
}

String getFormattedTime(Duration time) {
  return "${time.inMinutes.toString().padLeft(2, "0")}:${(time.inSeconds % 60).toString().padLeft(2, "0")}.${(((time.inMilliseconds % 1000) / 10).floor().toString().padLeft(2, "0"))}";
}
