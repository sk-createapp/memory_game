import 'package:flutter_riverpod/legacy.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/domain/growth.dart';
import 'package:memory_game/model/level_infos.dart';

//レベルごとの情報管理
final levelInfosProvider =
    StateNotifierProvider<LevelInfoNotifier, List<LevelInfo>>((ref) {
  return LevelInfoNotifier();
});

class LevelInfoNotifier extends StateNotifier<List<LevelInfo>> {
  LevelInfoNotifier()
      : super([
          for (int i = 0; i < DefNum.maxLevel; i++)
            LevelInfo(
              recordInfos: const [],
              isLocked: i >= DefNum.defaultLockedLevel,
            )
        ]) {
    _loadLevelInfos();
  }

  Future<void> _loadLevelInfos() async {
    final levelInfos = await LevelInfo.getLevelInfos();
    if (levelInfos != null) {
      state = List.of(levelInfos.map((e) => e.copy()));
    }
  }

  Future<void> _saveLevelInfos() async {
    await LevelInfo.saveLevelInfos(state);
  }

  //レコードの追加。育成EXPを加算し、加算結果（段階アップ判定用）を返す。
  GrowthGain addRecord(int levelIndex, RecordInfo recordInfo) {
    final nextState = List<LevelInfo>.of(state);
    final current = nextState[levelIndex];

    final nextRecords = [
      ...current.recordInfos,
      recordInfo,
    ]..sort((a, b) => a.memorizeTime.compareTo(b.memorizeTime));

    //育成EXPを加算（速いほど多い）。
    final gained =
        gainedExp(level: levelIndex, time: recordInfo.memorizeTime);
    final beforeExp = current.exp;
    final afterExp = clampExp(beforeExp + gained);

    nextState[levelIndex] = current.copyWith(
      recordInfos: nextRecords.take(DefNum.recordNum).toList(),
      exp: afterExp,
    );

    if (levelIndex + 1 < nextState.length &&
        nextState[levelIndex + 1].isLocked) {
      nextState[levelIndex + 1] =
          nextState[levelIndex + 1].copyWith(isLocked: false);
    }

    state = nextState;

    //SP保存
    _saveLevelInfos();

    return GrowthGain(
      gainedExp: gained,
      totalExp: afterExp,
      before: stageForExp(beforeExp),
      after: stageForExp(afterExp),
    );
  }
}
