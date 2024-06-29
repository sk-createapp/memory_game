import 'dart:convert';

import 'package:memory_game/constant/sp_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

//記録管理
class RecordInfo {
  final Duration memorizeTime;
  final DateTime recordedDate;

  RecordInfo({
    required this.memorizeTime,
    required this.recordedDate,
  });

  RecordInfo copy() {
    return RecordInfo(
      memorizeTime: memorizeTime,
      recordedDate: recordedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memorizeTime': memorizeTime.toString(),
      'recordedDate': recordedDate.toString(),
    };
  }

  static RecordInfo fromJson(Map<String, dynamic> json) {
    int hours = int.parse(json['memorizeTime'].toString().split(":")[0]);
    int minutes = int.parse(json['memorizeTime'].toString().split(":")[1]);
    int seconds =
        int.parse(json['memorizeTime'].toString().split(":")[2].split(".")[0]);
    int microseconds = int.parse(json['memorizeTime'].toString().split(".")[1]);

    return RecordInfo(
      memorizeTime: Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        microseconds: microseconds,
      ),
      recordedDate: DateTime.parse(json['recordedDate']),
    );
  }
}

//レベルごとの情報
class LevelInfo {
  List<RecordInfo> recordInfos;
  bool isLocked;

  LevelInfo({
    required this.recordInfos,
    this.isLocked = false,
  });

  LevelInfo copy() {
    return LevelInfo(
      recordInfos: List.of(recordInfos.map((e) => e.copy())),
      isLocked: isLocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordInfos': recordInfos.map((e) => e.toJson()).toList(),
      'isLocked': isLocked,
    };
  }

  static LevelInfo fromJson(Map<String, dynamic> json) {
    return LevelInfo(
      recordInfos: json['recordInfos']
          .map<RecordInfo>((e) => RecordInfo.fromJson(e))
          .toList(),
      isLocked: json['isLocked'],
    );
  }

  // SP保存
  static Future<void> saveLevelInfos(List<LevelInfo> levelInfos) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String json =
        levelInfos.map((e) => jsonEncode(e.toJson())).toList().toString();
    await prefs.setString(SpKey.levelInfos.name, json);
  }

  // SP取得
  static Future<List> getLevelInfos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(SpKey.levelInfos.name);
    if (json == null) {
      return Future<List<LevelInfo>>.value([]);
    } else {
      return Future<List>.value(
          jsonDecode(json).map((e) => LevelInfo.fromJson(e)).toList());
    }
  }
}
