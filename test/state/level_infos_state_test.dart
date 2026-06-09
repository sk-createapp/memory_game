import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/model/level_infos.dart';
import 'package:memory_game/state/level_infos_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('initializes default locked levels', () {
    SharedPreferences.setMockInitialValues({});
    final notifier = LevelInfoNotifier();

    expect(notifier.state, hasLength(DefNum.maxLevel));
    expect(notifier.state[DefNum.defaultLockedLevel - 1].isLocked, isFalse);
    expect(notifier.state[DefNum.defaultLockedLevel].isLocked, isTrue);
  });

  test(
      'addRecord sorts, caps, unlocks next level, and keeps old state untouched',
      () async {
    SharedPreferences.setMockInitialValues({});
    final notifier = LevelInfoNotifier();
    final before = notifier.state;

    for (int i = 0; i < DefNum.recordNum + 2; i++) {
      notifier.addRecord(
        DefNum.defaultLockedLevel - 1,
        RecordInfo(
          memorizeTime: Duration(seconds: DefNum.recordNum + 2 - i),
          recordedDate: DateTime.utc(2026, 6, 9),
        ),
      );
    }
    await Future<void>.delayed(Duration.zero);

    final records = notifier.state[DefNum.defaultLockedLevel - 1].recordInfos;
    expect(before[DefNum.defaultLockedLevel - 1].recordInfos, isEmpty);
    expect(records, hasLength(DefNum.recordNum));
    expect(records.map((record) => record.memorizeTime.inSeconds),
        orderedEquals(List.generate(DefNum.recordNum, (index) => index + 1)));
    expect(notifier.state[DefNum.defaultLockedLevel].isLocked, isFalse);
  });
}
