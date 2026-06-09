import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/model/item_table_info.dart';
import 'package:memory_game/model/level_infos.dart';
import 'package:memory_game/view/util/util.dart';

void main() {
  group('getItemChoices', () {
    test('uses the provided icon list and includes all answer icons', () {
      const tableItems = [
        TableItem(icon: 'a.png', isShowItem: true, isAnswerItem: true),
        TableItem(icon: 'b.png', isShowItem: true, isAnswerItem: true),
        TableItem(icon: 'c.png', isShowItem: true, isAnswerItem: false),
      ];
      final choices = getItemChoices(
        4,
        tableItems,
        ['a.png', 'b.png', 'c.png', 'd.png', 'e.png'],
        random: Random(1),
      );

      expect(choices, hasLength(4));
      expect(choices, containsAll(['a.png', 'b.png']));
      expect(choices.every((choice) => choice.endsWith('.png')), isTrue);
    });
  });

  test('isAllCorrect only passes when every answer item matches', () {
    const correctItems = [
      TableItem(
          icon: 'a.png',
          answeredIcon: 'a.png',
          isShowItem: true,
          isAnswerItem: true),
      TableItem(
          icon: 'b.png',
          answeredIcon: 'b.png',
          isShowItem: true,
          isAnswerItem: true),
    ];
    const incorrectItems = [
      TableItem(
          icon: 'a.png',
          answeredIcon: 'x.png',
          isShowItem: true,
          isAnswerItem: true),
      TableItem(
          icon: 'b.png',
          answeredIcon: 'b.png',
          isShowItem: true,
          isAnswerItem: true),
    ];

    expect(isAllCorrect(correctItems, 2), isTrue);
    expect(isAllCorrect(incorrectItems, 2), isFalse);
  });

  test('isCompletedAnswer counts answered cells against table answer count',
      () {
    const table = ItemTableInfo(
      tableItems: [
        TableItem(
            icon: 'a.png',
            answeredIcon: 'a.png',
            isShowItem: true,
            isAnswerItem: true),
        TableItem(icon: 'b.png', isShowItem: true, isAnswerItem: true),
      ],
      columnNum: 2,
      rowNum: 2,
      answerItemNum: 2,
    );

    expect(isCompletedAnswer(table), isFalse);
  });

  test('getLockedLevel returns the first locked level or length + 1', () {
    expect(
      getLockedLevel([
        const LevelInfo(recordInfos: []),
        const LevelInfo(recordInfos: [], isLocked: true),
        const LevelInfo(recordInfos: [], isLocked: true),
      ]),
      1,
    );
    expect(
      getLockedLevel([
        const LevelInfo(recordInfos: []),
        const LevelInfo(recordInfos: []),
      ]),
      3,
    );
  });

  test('getRank returns the highest cleared level or -1', () {
    final emptyLevels = [
      const LevelInfo(recordInfos: []),
      const LevelInfo(recordInfos: []),
    ];
    final clearedLevels = [
      const LevelInfo(recordInfos: []),
      LevelInfo(
        recordInfos: [
          RecordInfo(
            memorizeTime: const Duration(seconds: 1),
            recordedDate: DateTime.utc(2026, 6, 9),
          ),
        ],
      ),
    ];

    expect(getRank(emptyLevels), -1);
    expect(getRank(clearedLevels), 1);
  });

  test('getFormattedTime formats centiseconds', () {
    expect(
      getFormattedTime(
          const Duration(minutes: 2, seconds: 3, milliseconds: 45)),
      '02:03.04',
    );
  });
}
