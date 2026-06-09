import 'dart:convert';

import 'package:memory_game/constant/sp_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

//記録管理
class RecordInfo {
  final Duration memorizeTime;
  final DateTime recordedDate;

  const RecordInfo({
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
      'memorizeTimeMicroseconds': memorizeTime.inMicroseconds,
      'recordedDate': recordedDate.toIso8601String(),
    };
  }

  static RecordInfo fromJson(Map<String, dynamic> json) {
    return RecordInfo(
      memorizeTime: _parseDuration(json),
      recordedDate: DateTime.parse(json['recordedDate'] as String),
    );
  }

  static Duration _parseDuration(Map<String, dynamic> json) {
    final microseconds = json['memorizeTimeMicroseconds'];
    if (microseconds is int) {
      return Duration(microseconds: microseconds);
    }

    final value = json['memorizeTime'].toString();
    final parts = value.split(':');
    final secondsParts = parts[2].split('.');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(secondsParts[0]),
      microseconds: int.parse(secondsParts[1]),
    );
  }
}

//レベルごとの情報
class LevelInfo {
  final List<RecordInfo> recordInfos;
  final bool isLocked;

  const LevelInfo({
    required this.recordInfos,
    this.isLocked = false,
  });

  LevelInfo copyWith({
    List<RecordInfo>? recordInfos,
    bool? isLocked,
  }) {
    return LevelInfo(
      recordInfos: List.unmodifiable(recordInfos ?? this.recordInfos),
      isLocked: isLocked ?? this.isLocked,
    );
  }

  LevelInfo copy() => copyWith();

  Map<String, dynamic> toJson() {
    return {
      'recordInfos': recordInfos.map((e) => e.toJson()).toList(),
      'isLocked': isLocked,
    };
  }

  static LevelInfo fromJson(Map<String, dynamic> json) {
    final recordInfos = json['recordInfos'] as List<dynamic>;
    return LevelInfo(
      recordInfos: List.unmodifiable(recordInfos
          .cast<Map<String, dynamic>>()
          .map<RecordInfo>(RecordInfo.fromJson)),
      isLocked: json['isLocked'] as bool,
    );
  }

  // SP保存
  static Future<void> saveLevelInfos(List<LevelInfo> levelInfos) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String json = jsonEncode(levelInfos.map((e) => e.toJson()).toList());
    await prefs.setString(SpKey.levelInfos.name, json);
  }

  // SP取得
  static Future<List<LevelInfo>?> getLevelInfos() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? json = prefs.getString(SpKey.levelInfos.name);
      if (json == null) {
        return null;
      } else {
        final decoded = jsonDecode(json) as List<dynamic>;
        return decoded
            .cast<Map<String, dynamic>>()
            .map<LevelInfo>(LevelInfo.fromJson)
            .toList();
      }
    } catch (e) {
      return null;
    }
  }
}
