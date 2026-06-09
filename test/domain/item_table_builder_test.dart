import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/domain/item_table_builder.dart';

void main() {
  List<String> icons(int count) =>
      List.generate(count, (index) => 'icon-$index.png');

  group('ItemTableBuilder', () {
    test('builds a 4x4 table for the first level', () {
      final table =
          ItemTableBuilder(random: Random(1), icons: icons(50)).build(0);

      expect(table.columnNum, 4);
      expect(table.rowNum, 4);
      expect(table.tableItems, hasLength(16));
      expect(table.answerItemNum, DefNum.answerNum);
      expect(table.tableItems.where((item) => item.isShowItem), hasLength(3));
      expect(table.tableItems.where((item) => item.isAnswerItem), hasLength(3));
    });

    test('chooses the grid size from the number of visible items', () {
      final builder = ItemTableBuilder(random: Random(1), icons: icons(50));

      expect(builder.build(6).rowNum, 4);
      expect(builder.build(7).rowNum, 5);
      expect(builder.build(17).rowNum, 6);
      expect(builder.build(27).rowNum, 7);
    });

    test('visible items have unique positions and unique icons', () {
      final table =
          ItemTableBuilder(random: Random(2), icons: icons(100)).build(19);
      final visibleItems = table.tableItems.where((item) => item.isShowItem);
      final visibleIcons = visibleItems.map((item) => item.icon).toList();

      expect(visibleItems, hasLength(22));
      expect(visibleIcons.toSet(), hasLength(visibleIcons.length));
      expect(
        table.tableItems.where((item) => item.isAnswerItem && item.isShowItem),
        hasLength(DefNum.answerNum),
      );
    });

    test('throws when there are not enough icons for unique visible items', () {
      final builder = ItemTableBuilder(random: Random(1), icons: icons(2));

      expect(() => builder.build(0), throwsStateError);
    });
  });
}
