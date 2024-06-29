import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/num_constant.dart';

//HomeViewのステート管理
enum HomeState {
  home,
  memorize,
  answer,
  finished,
}

//HomeViewのステート管理
final homeStateProvider = StateProvider<HomeState>((ref) => HomeState.home);
//選択中のゲームレベル
final gameLevelProvider = StateProvider<int>((ref) => 0);
//回答アイテムの高さ管理
final answerItemHeightsProvider = StateProvider<List<double>>(
    (ref) => List<double>.filled(DefNum.answerNum, 0));
