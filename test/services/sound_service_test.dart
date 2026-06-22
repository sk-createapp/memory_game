import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/services/sound_service.dart';

/// SoundService の「音はあくまで装飾。設定オフや未初期化でも安全に何もしない」
/// という契約を検証する。実機プラグインに依存しない範囲のみを対象とする
/// （init() はプラットフォーム実装が必要なため、ここでは呼ばない）。
void main() {
  final sound = SoundService.instance;

  test('setEnabled で enabled フラグが切り替わる', () {
    sound.setEnabled(false);
    expect(sound.enabled, isFalse);
    sound.setEnabled(true);
    expect(sound.enabled, isTrue);
  });

  test('オフのときは再生を呼んでも例外を投げない', () async {
    sound.setEnabled(false);
    await sound.playTap();
    await sound.playResult(ResultSound.clear);
    await sound.playResult(ResultSound.fanfare);
    await sound.playResult(ResultSound.failure);
  });

  test('オンでも未初期化（プレイヤー未生成）なら安全に何もしない', () async {
    sound.setEnabled(true);
    // tapPool / resultPlayer が未生成でも null 参照や例外にならない。
    await sound.playTap();
    await sound.playResult(ResultSound.clear);
  });
}
