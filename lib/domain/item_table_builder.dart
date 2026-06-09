import 'dart:math';

import 'package:memory_game/constant/image_path.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/model/item_table_info.dart';

class ItemTableBuilder {
  ItemTableBuilder({
    Random? random,
    List<String> icons = defImages,
  })  : _random = random ?? Random(),
        _icons = List.unmodifiable(icons);

  final Random _random;
  final List<String> _icons;

  ItemTableInfo build(int gameLevel) {
    final showItemNum = gameLevel + DefNum.answerNum;
    final gridSize = _gridSizeFor(showItemNum);
    final itemNum = gridSize * gridSize;
    final cappedShowItemNum = min(showItemNum, itemNum);
    final answerItemNum = min(DefNum.answerNum, cappedShowItemNum);

    return ItemTableInfo(
      tableItems: _buildTableItems(
        itemNum: itemNum,
        showItemNum: cappedShowItemNum,
        answerItemNum: answerItemNum,
      ),
      columnNum: gridSize,
      rowNum: gridSize,
      answerItemNum: answerItemNum,
    );
  }

  int _gridSizeFor(int showItemNum) {
    if (showItemNum < 10) {
      return 4;
    }
    if (showItemNum < 20) {
      return 5;
    }
    if (showItemNum < 30) {
      return 6;
    }
    if (showItemNum < 40) {
      return 7;
    }
    return 4;
  }

  List<TableItem> _buildTableItems({
    required int itemNum,
    required int showItemNum,
    required int answerItemNum,
  }) {
    final showItemIndexes = _randomIndexes(showItemNum, itemNum);
    final answerItemIndexes = showItemIndexes.take(answerItemNum).toSet();
    final icons = _randomIcons(showItemNum);
    var iconIndex = 0;

    return [
      for (int i = 0; i < itemNum; i++)
        if (!showItemIndexes.contains(i))
          const TableItem(isShowItem: false, isAnswerItem: false)
        else
          TableItem(
            icon: icons[iconIndex++],
            isShowItem: true,
            isAnswerItem: answerItemIndexes.contains(i),
          ),
    ];
  }

  Set<int> _randomIndexes(int count, int range) {
    final indexes = List<int>.generate(range, (index) => index)
      ..shuffle(_random);
    return indexes.take(count).toSet();
  }

  List<String> _randomIcons(int count) {
    if (count > _icons.length) {
      throw StateError('Not enough icons to create a unique item table.');
    }
    final icons = List<String>.of(_icons)..shuffle(_random);
    return icons.take(count).toList();
  }
}
