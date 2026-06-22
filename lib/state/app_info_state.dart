import 'package:flutter_riverpod/legacy.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

//HomeViewのステート管理
enum HomeState {
  home,
  memorize,
  answer,
  finished,
}

//HomeViewのステート管理
final homeStateProvider = StateProvider<HomeState>((ref) => HomeState.home);

// 前回プレイレベルが未保存・読込失敗のときに使う初期レベル。
const int _defaultGameLevel = 0;

//選択中のゲームレベル。前回プレイしたレベルをSPへ保存し、次回起動時に復元する。
//初期値は main() で起動前に読み込み、ProviderScope の override で注入する
//（未注入時はフォールバックのレベル0で生成される）。
final gameLevelProvider = StateNotifierProvider<GameLevelNotifier, int>(
    (ref) => GameLevelNotifier(_defaultGameLevel));

class GameLevelNotifier extends StateNotifier<int> {
  GameLevelNotifier(super.initialLevel);

  // 起動前ロード用。前回プレイしたレベルをSPから読み込む。
  // 未保存・読込失敗・保存値が不正（範囲外）の場合はレベル0へフォールバックする。
  static Future<int> restoreLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(SpKey.lastPlayedLevel.name);
      if (saved == null) return _defaultGameLevel;
      return saved.clamp(0, DefNum.maxLevel - 1);
    } catch (_) {
      // SP読込失敗時もアプリは通常起動させ、レベル0から開始する。
      return _defaultGameLevel;
    }
  }

  // ピッカーでの選択。表示を切り替えるだけで、永続化はプレイ開始時に行う。
  void select(int level) {
    state = level;
  }

  // プレイ開始時に「前回プレイしたレベル」として現在の選択を永続化する。
  // 保存失敗は致命的でないため握りつぶす（次回は前回の保存値が使われる）。
  Future<void> persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(SpKey.lastPlayedLevel.name, state);
    } catch (_) {
      // 永続化に失敗しても進行は妨げない。
    }
  }
}
//回答アイテムの高さ管理
final answerItemHeightsProvider = StateProvider<List<double>>(
    (ref) => List<double>.filled(DefNum.answerNum, 0));
