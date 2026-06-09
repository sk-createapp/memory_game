import 'package:flutter_riverpod/legacy.dart';
import 'package:memory_game/domain/item_table_builder.dart';
import 'package:memory_game/model/item_table_info.dart';

//アイテムテーブルの管理
final itemTableInfoProvider =
    StateNotifierProvider<ItemTableInfoNotifier, ItemTableInfo>((ref) {
  return ItemTableInfoNotifier();
});

class ItemTableInfoNotifier extends StateNotifier<ItemTableInfo> {
  ItemTableInfoNotifier({
    ItemTableBuilder? builder,
  })  : _builder = builder ?? ItemTableBuilder(),
        super(const ItemTableInfo(
          tableItems: [],
          columnNum: 0,
          rowNum: 0,
          answerItemNum: 0,
        ));

  final ItemTableBuilder _builder;

  // 記憶時間を設定する
  void setMemorizeTime(Duration memorizeTime) {
    state = state.copyWith(memorizeTime: memorizeTime);
  }

  //新しいテーブルの生成
  void createTableItems(int gameLevel) {
    state = _builder.build(gameLevel);
  }

  //回答の記録
  void answerItem(int answerTableItemIndex, String choicedIcon) {
    state = state.copyWith(
      tableItems: [
        for (int i = 0; i < state.tableItems.length; i++)
          i == answerTableItemIndex
              ? state.tableItems[i].copyWith(answeredIcon: choicedIcon)
              : state.tableItems[i].copyWith(),
      ],
    );
  }
}
