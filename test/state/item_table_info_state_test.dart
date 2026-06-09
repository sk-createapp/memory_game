import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/domain/item_table_builder.dart';
import 'package:memory_game/state/item_table_info_state.dart';

void main() {
  test('answerItem updates the selected item without mutating previous state',
      () {
    final notifier = ItemTableInfoNotifier(
      builder: ItemTableBuilder(
        random: Random(1),
        icons: List.generate(50, (index) => 'icon-$index.png'),
      ),
    )..createTableItems(0);
    final before = notifier.state;
    final answerIndex = before.answerItemIndexes.first;
    final previousItem = before.tableItems[answerIndex];

    notifier.answerItem(answerIndex, 'choice.png');

    expect(before.tableItems[answerIndex], same(previousItem));
    expect(before.tableItems[answerIndex].answeredIcon, isNull);
    expect(notifier.state.tableItems[answerIndex].answeredIcon, 'choice.png');
  });
}
