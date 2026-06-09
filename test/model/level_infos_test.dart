import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:memory_game/model/level_infos.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RecordInfo', () {
    test('round-trips using microseconds and ISO date strings', () {
      final record = RecordInfo(
        memorizeTime: const Duration(minutes: 1, seconds: 2, milliseconds: 345),
        recordedDate: DateTime.utc(2026, 6, 9, 10, 11, 12),
      );

      final decoded = RecordInfo.fromJson(record.toJson());

      expect(decoded.memorizeTime, record.memorizeTime);
      expect(decoded.recordedDate, record.recordedDate);
    });

    test('can still read the previous Duration.toString format', () {
      final decoded = RecordInfo.fromJson({
        'memorizeTime': '0:01:02.003004',
        'recordedDate': '2026-06-09 10:11:12.000',
      });

      expect(
        decoded.memorizeTime,
        const Duration(minutes: 1, seconds: 2, microseconds: 3004),
      );
      expect(decoded.recordedDate, DateTime(2026, 6, 9, 10, 11, 12));
    });
  });

  group('LevelInfo persistence', () {
    test('saves valid JSON and restores typed level info', () async {
      SharedPreferences.setMockInitialValues({});
      final levelInfos = [
        LevelInfo(
          recordInfos: [
            RecordInfo(
              memorizeTime: const Duration(seconds: 3),
              recordedDate: DateTime.utc(2026, 6, 9),
            ),
          ],
        ),
        const LevelInfo(recordInfos: [], isLocked: true),
      ];

      await LevelInfo.saveLevelInfos(levelInfos);

      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(SpKey.levelInfos.name);
      expect(rawJson, isNotNull);
      expect(jsonDecode(rawJson!), isA<List<dynamic>>());

      final restored = await LevelInfo.getLevelInfos();
      expect(restored, hasLength(2));
      expect(restored![0].recordInfos.single.memorizeTime,
          const Duration(seconds: 3));
      expect(restored[1].isLocked, isTrue);
    });
  });
}
