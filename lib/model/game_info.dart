import 'dart:convert';

import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

//ゲーム情報管理
class GameInfo {
  final double appVersion;
  final int clearNum;
  GameInfo({
    required this.appVersion,
    required this.clearNum,
  });

  GameInfo copyWith({
    double? appVersion,
    int? clearNum,
  }) {
    return GameInfo(
      appVersion: appVersion ?? this.appVersion,
      clearNum: clearNum ?? this.clearNum,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appVersion': appVersion,
      'clearNum': clearNum,
    };
  }

  static GameInfo fromJson(Map<String, dynamic> json) {
    return GameInfo(
      appVersion: json['appVersion'],
      clearNum: json['clearNum'],
    );
  }

  // SP保存
  static Future<void> saveGameInfo(GameInfo gameInfo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String json = jsonEncode(gameInfo.toJson()).toString();
    await prefs.setString(SpKey.gameInfo.name, json);
  }

  // SP取得
  static Future<GameInfo?> getGameInfo() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? json = prefs.getString(SpKey.gameInfo.name);
      if (json == null) {
        return null;
      } else {
        return Future<GameInfo>.value(GameInfo.fromJson(jsonDecode(json)));
      }
    } catch (e) {
      return null;
    }
  }
}
