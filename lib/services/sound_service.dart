import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 結果画面で鳴らす効果音の種類。
enum ResultSound {
  // クリア（全問正解）：勝利ジングル＋拍手。
  clear,
  // 新記録／段階アップ：ファンファーレ（複数からランダム）＋歓声。
  fanfare,
  // 失敗：やさしい「残念」のトランペット。
  failure,
}

/// 操作音（タップ）と結果画面の効果音の再生を一手に担うサービス。
///
/// - 操作音は低レイテンシのプレイヤー複数でラウンドロビン再生し、連打でも破綻しない。
/// - 結果音は「メロディ（ジングル/ファンファーレ）」と「群衆（拍手/歓声）」を
///   2つのプレイヤーで同時に重ねて鳴らす。音源は全長そのまま再生する。
/// - ホームに戻るときは [fadeOutResult] で結果音をフェードアウトさせる。
/// - ミュート設定（SharedPreferences）を保持し、オフのときは一切鳴らさない。
/// - 音はあくまで装飾なので、どの操作が失敗しても例外は投げず無音で続行する。
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  // 操作音は連打に耐えるよう数個のプレイヤーを使い回す。
  static const int _tapPoolSize = 4;
  final List<AudioPlayer> _tapPool = [];
  int _tapCursor = 0;

  // 結果音はメロディと群衆を重ねるため2系統。
  AudioPlayer? _jinglePlayer;
  AudioPlayer? _crowdPlayer;

  // フェードアウト用のタイマー（ホームに戻るとき）。
  Timer? _fadeTimer;

  final Random _random = Random();

  // 操作音は控えめ、結果音はしっかり。群衆音はメロディを邪魔しないよう少し下げる。
  static const double _tapVolume = 0.9;
  static const double _jingleVolume = 1.0;
  static const double _crowdVolume = 0.7;

  bool _enabled = true;
  bool _initialized = false;

  // 覚える・答えるなどのプレイ画面では、集中の妨げにならないよう操作音を止める。
  // （触覚フィードバックは別管理なのでそのまま残る）
  bool _tapSuppressed = false;

  static const String _tapAsset = 'sounds/tap.wav';
  // クリア：勝利ジングル＋拍手。
  static const String _clearJingle = 'sounds/clear_win.mp3';
  static const String _clearCrowd = 'sounds/clear_applause.mp3';
  // 新記録：ファンファーレ（この中からランダムに1つ）＋歓声。
  static const List<String> _fanfares = [
    'sounds/fanfare_1.mp3',
    'sounds/fanfare_2.mp3',
    'sounds/fanfare_3.mp3',
  ];
  static const String _newRecordCrowd = 'sounds/newrecord_cheer.mp3';
  // 失敗：トランペット（群衆音なし）。
  static const String _failJingle = 'sounds/fail.mp3';

  bool get enabled => _enabled;

  /// プレイ画面（覚える・答える）の間だけ操作音を抑制するためのフラグ。
  /// 画面の表示中に true、離れるときに false にする。触覚には影響しない。
  set suppressTaps(bool value) => _tapSuppressed = value;

  /// 起動時に一度呼ぶ。設定の読み込みとプレイヤーの先読みを行う。
  /// UIの起動はブロックしないよう、main から fire-and-forget で呼ぶ想定。
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(SpKey.soundEnabled.name) ?? true;
    } catch (_) {
      _enabled = true;
    }

    try {
      // 効果音が利用者の音楽・ポッドキャストを止めたり小さくしたりしないよう、
      // オーディオフォーカスを奪わず「他の音と混ぜる」設定にする。
      // （アプリ内のオン/オフ設定を音の有無の唯一の窓口にしたいので、
      //  iOSのサイレントスイッチには従わせない＝既定の respectSilence: false）
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers)
            .build(),
      );

      for (var i = 0; i < _tapPoolSize; i++) {
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setVolume(_tapVolume);
        // 先読みして初回タップの遅延を抑える。
        await player.setSource(AssetSource(_tapAsset));
        _tapPool.add(player);
      }

      _jinglePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _crowdPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    } catch (_) {
      // 一部プラットフォームで初期化に失敗しても、再生時に握りつぶす。
    }
  }

  /// ミュート設定を切り替える（実行時のフラグのみ。永続化は呼び出し側で行う）。
  void setEnabled(bool value) {
    _enabled = value;
    if (!value) {
      // オフにした瞬間に鳴っている結果音は止める。
      _fadeTimer?.cancel();
      _stopQuietly(_jinglePlayer);
      _stopQuietly(_crowdPlayer);
    }
  }

  /// 操作音（タップ）を鳴らす。連打でも破綻しないようプールを使い回す。
  /// プレイ画面では [_tapSuppressed] により鳴らさない（集中のため）。
  Future<void> playTap() async {
    if (!_enabled || _tapSuppressed || _tapPool.isEmpty) return;
    final player = _tapPool[_tapCursor];
    _tapCursor = (_tapCursor + 1) % _tapPool.length;
    try {
      // 低レイテンシモードでは play() で都度頭出し再生する（音源は init で
      // 先読み済み・AudioCache にキャッシュされるため負荷は小さい）。
      await player.play(AssetSource(_tapAsset), volume: _tapVolume);
    } catch (_) {
      // 鳴らせなくても無視する。
    }
  }

  /// 結果画面の効果音を鳴らす。メロディと群衆を重ねて全長そのまま再生する。
  Future<void> playResult(ResultSound kind) async {
    if (!_enabled) return;
    // 進行中のフェードがあれば止め、音量を既定へ戻して鳴らし直す。
    _fadeTimer?.cancel();
    try {
      switch (kind) {
        case ResultSound.clear:
          await _play(_jinglePlayer, _clearJingle, _jingleVolume);
          await _play(_crowdPlayer, _clearCrowd, _crowdVolume);
        case ResultSound.fanfare:
          final fanfare = _fanfares[_random.nextInt(_fanfares.length)];
          await _play(_jinglePlayer, fanfare, _jingleVolume);
          await _play(_crowdPlayer, _newRecordCrowd, _crowdVolume);
        case ResultSound.failure:
          _stopQuietly(_crowdPlayer);
          await _play(_jinglePlayer, _failJingle, _jingleVolume);
      }
    } catch (_) {
      // 鳴らせなくても無視する。
    }
  }

  /// 結果音を [duration] かけてなめらかに小さくし、止める。
  /// 途中でホーム画面へ戻るときに呼ぶ。何も鳴っていなければ無害。
  Future<void> fadeOutResult({
    Duration duration = const Duration(milliseconds: 600),
  }) async {
    _fadeTimer?.cancel();
    // (プレイヤー, 元の音量) の組。未初期化なら何もしない。
    final targets = <MapEntry<AudioPlayer, double>>[
      if (_jinglePlayer != null) MapEntry(_jinglePlayer!, _jingleVolume),
      if (_crowdPlayer != null) MapEntry(_crowdPlayer!, _crowdVolume),
    ];
    if (targets.isEmpty) return;

    const steps = 12;
    final stepMs = max(1, duration.inMilliseconds ~/ steps);
    var step = 0;
    _fadeTimer = Timer.periodic(Duration(milliseconds: stepMs), (timer) {
      step++;
      final factor = (1.0 - step / steps).clamp(0.0, 1.0);
      for (final t in targets) {
        try {
          t.key.setVolume(t.value * factor);
        } catch (_) {}
      }
      if (step >= steps) {
        timer.cancel();
        for (final t in targets) {
          _stopQuietly(t.key);
        }
      }
    });
  }

  /// 指定プレイヤーで [asset] を [volume] で頭から鳴らす（前の再生は止める）。
  Future<void> _play(AudioPlayer? player, String asset, double volume) async {
    if (player == null) return;
    await player.stop();
    await player.play(AssetSource(asset), volume: volume);
  }

  void _stopQuietly(AudioPlayer? player) {
    try {
      player?.stop();
    } catch (_) {}
  }
}
