import 'package:flutter_riverpod/legacy.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:memory_game/services/sound_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 効果音（操作音・結果音）のオン/オフ設定。
///
/// 設定値は SharedPreferences に永続化し、実際の再生を担う [SoundService] にも
/// 反映する。メニューのトグルがこの状態を読み書きする。
final soundEnabledProvider =
    StateNotifierProvider<SoundEnabledNotifier, bool>((ref) {
  return SoundEnabledNotifier();
});

class SoundEnabledNotifier extends StateNotifier<bool> {
  // SoundService が起動時に読み込んだ値を初期表示に使う（既定はオン）。
  SoundEnabledNotifier() : super(SoundService.instance.enabled) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(SpKey.soundEnabled.name) ?? true;
    state = enabled;
    SoundService.instance.setEnabled(enabled);
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    SoundService.instance.setEnabled(value);
    // オンに切り替えたときは、効いていることが分かるよう操作音を一度鳴らす。
    if (value) {
      SoundService.instance.playTap();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SpKey.soundEnabled.name, value);
  }

  Future<void> toggle() => setEnabled(!state);
}
