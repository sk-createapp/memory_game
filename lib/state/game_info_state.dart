import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:memory_game/model/game_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ゲーム情報の管理
final gameInfoProvider =
    StateNotifierProvider<GameInfoNotifier, GameInfo>((ref) {
  return GameInfoNotifier();
});

class GameInfoNotifier extends StateNotifier<GameInfo> {
  GameInfoNotifier()
      : super(GameInfo(appVersion: DefNum.appVersion, clearNum: 0)) {
    _loadGameInfo();

    //アプリがバージョンアップしていたらバージョン情報を更新
    if (state.appVersion != DefNum.appVersion) {
      state = state.copyWith(appVersion: DefNum.appVersion);
      _saveGameInfo();
    }
  }

  Future<void> _loadGameInfo() async {
    state = await GameInfo.getGameInfo() ?? state;
  }

  Future<void> _saveGameInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String json = jsonEncode(state.toJson());
    await prefs.setString(SpKey.gameInfo.name, json);
  }

  void incrementClearNum() {
    state = state.copyWith(clearNum: state.clearNum + 1);

    //SP保存
    _saveGameInfo();
  }
}
