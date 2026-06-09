import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:memory_game/model/game_info.dart';
import 'package:memory_game/state/game_info_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads saved clear count and migrates the app version', () async {
    SharedPreferences.setMockInitialValues({
      SpKey.gameInfo.name: jsonEncode(
        const GameInfo(appVersion: 0.5, clearNum: 7).toJson(),
      ),
    });

    final notifier = GameInfoNotifier();
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.clearNum, 7);
    expect(notifier.state.appVersion, DefNum.appVersion);
  });

  test('incrementClearNum updates state and persists it', () async {
    SharedPreferences.setMockInitialValues({});
    final notifier = GameInfoNotifier();

    notifier.incrementClearNum();
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.clearNum, 1);
    final prefs = await SharedPreferences.getInstance();
    final saved = GameInfo.fromJson(
      jsonDecode(prefs.getString(SpKey.gameInfo.name)!) as Map<String, dynamic>,
    );
    expect(saved.clearNum, 1);
  });
}
