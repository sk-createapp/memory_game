import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/image_path.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/model/item_table_info.dart';

//アイテムテーブルの管理
final itemTableInfoProvider =
    StateNotifierProvider<ItemTableInfoNotifier, ItemTableInfo>((ref) {
  return ItemTableInfoNotifier();
});

class ItemTableInfoNotifier extends StateNotifier<ItemTableInfo> {
  ItemTableInfoNotifier()
      : super(ItemTableInfo(
          tableItems: [],
          columnNum: 0,
          rowNum: 0,
          answerItemNum: 0,
        ));

  //アイテムのリストを生成し取得
  List<TableItem> _getTableItems(
      int itemNum, int showItemNum, int answerItemNum) {
    List<TableItem> tableItems = [];
    List<int> showItemIndexies = [];
    List<int> answerItemIndexies = [];

    //表示するアイテムのテーブルインデックスを決定する
    showItemIndexies = _getDifferentRandomNumList(showItemNum, itemNum);

    if (showItemNum > answerItemNum) {
      //回答するアイテムのテーブルインデックスを決定する
      answerItemIndexies = List.of(showItemIndexies);
      answerItemIndexies.shuffle();
      answerItemIndexies.removeRange(answerItemNum, showItemNum);
    }

    for (int i = 0; i < itemNum; i++) {
      if (showItemIndexies.contains(i) == false &&
          answerItemIndexies.contains(i) == false) {
        //空
        tableItems.add(TableItem(isShowItem: false, isAnswerItem: false));
      } else {
        if (answerItemIndexies.contains(i) ||
            showItemIndexies.contains(i) && showItemNum <= answerItemNum) {
          //回答対象
          tableItems.add(TableItem(
              icon: defImages[Random().nextInt(defImages.length)],
              isShowItem: true,
              isAnswerItem: true));
        } else if (showItemIndexies.contains(i)) {
          //表示
          tableItems.add(TableItem(
              icon: defImages[Random().nextInt(defImages.length)],
              isShowItem: true,
              isAnswerItem: false));
        }
      }
    }
    return List.of(tableItems);
  }

  // 表示するアイテムを重複がないようにランダムに決める
  List<int> _getDifferentRandomNumList(int num, int range) {
    List<int> ret = [];
    for (int i = 0; i < range; i++) {
      ret.add(i);
    }
    ret.shuffle();
    ret.removeRange(num, ret.length);

    return ret;
  }

  // 記憶時間を設定する
  void setMemorizeTime(Duration memorizeTime) {
    state = state.copyWith(memorizeTime: memorizeTime);
  }

  //新しいテーブルの生成
  void createTableItems(int gameLevel) {
    int columnNum;
    int rowNum;
    int answerItemNum = DefNum.answerNum;
    int showItemNum = gameLevel + DefNum.answerNum;

    //行数・列数を設定
    if (showItemNum < 10) {
      columnNum = 4;
      rowNum = 4;
    } else if (10 <= showItemNum && showItemNum < 20) {
      columnNum = 5;
      rowNum = 5;
    } else if (20 <= showItemNum && showItemNum < 30) {
      columnNum = 6;
      rowNum = 6;
    } else if (30 <= showItemNum && showItemNum < 40) {
      columnNum = 7;
      rowNum = 7;
    } else {
      columnNum = 4;
      rowNum = 4;
    }

    if (showItemNum < answerItemNum) {
      answerItemNum = showItemNum;
    }

    final itemNum = columnNum * rowNum;

    // テーブルの要素数よりshowItemNumが大きい場合のエラー処理
    if (showItemNum > itemNum) {
      showItemNum = itemNum;
    }

    //テーブルアイテムのリストを取得
    List<TableItem> tableItems =
        _getTableItems(itemNum, showItemNum, answerItemNum);
    state = ItemTableInfo(
        tableItems: tableItems,
        columnNum: columnNum,
        rowNum: rowNum,
        answerItemNum: answerItemNum);
  }

  //回答の記録
  void answerItem(int answerTableItemIndex, String choicedIcon) {
    state.tableItems[answerTableItemIndex].answeredIcon = choicedIcon;
    //アイテムテーブル更新
    state = state.copyWith();
  }
}
