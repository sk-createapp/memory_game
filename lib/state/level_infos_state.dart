import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/num_constant.dart';
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
                recordInfos: [],
                isLocked: (i >= DefNum.defaultLockedLevel) ? true : false)
        ]) {
    _loadLevelInfos();
  }

  Future<void> _loadLevelInfos() async {
    List? levelInfos = (await LevelInfo.getLevelInfos());
    if (levelInfos != null) {
      state = List.of(levelInfos.cast<LevelInfo>().map((e) => e.copy()));
    }
  }

  Future<void> _saveLevelInfos() async {
    await LevelInfo.saveLevelInfos(state);
  }

  //レコードの追加
  void addRecord(int levelIndex, RecordInfo recordInfo) {
    state[levelIndex].recordInfos.add(recordInfo);

    //レコードをソート
    state[levelIndex]
        .recordInfos
        .sort((a, b) => a.memorizeTime.compareTo(b.memorizeTime));

    //レコード数は10以内にする
    while (state[levelIndex].recordInfos.length > DefNum.recordNum) {
      state[levelIndex].recordInfos.removeLast();
    }

    //次のレベルがロックされていたら解除する
    if (levelIndex + 1 < state.length && state[levelIndex + 1].isLocked) {
      state[levelIndex + 1].isLocked = false;
    }

    state = List.of(state);

    //SP保存
    _saveLevelInfos();
  }
}
