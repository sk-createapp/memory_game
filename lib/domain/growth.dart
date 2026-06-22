import 'dart:math';

/// 育成機能のコアロジック。
///
/// 各レベルに相棒動物が1匹おり、クリア（全問正解）で得た経験値(EXP)が貯まると
/// 赤ちゃん→こども→わかもの→おとな→はかせ の5段階に育つ。EXPは「速いほど多い」。
/// アセットは手描きSVG（`assets/images/growth/<animal>_s<0-4>.svg`）。

/// レベル(0始まり)→動物キーの割当（小さい動物→大きい動物へエスカレーション）。
const List<String> growthAnimals = [
  'chick', // Lv1 ヒヨコ
  'mouse', // Lv2 ねずみ
  'rabbit', // Lv3 うさぎ
  'squirrel', // Lv4 りす
  'cat', // Lv5 ねこ
  'dog', // Lv6 いぬ
  'duck', // Lv7 あひる
  'pig', // Lv8 ぶた
  'sheep', // Lv9 ひつじ
  'fox', // Lv10 きつね
  'koala', // Lv11 コアラ
  'bear', // Lv12 くま
  'panda', // Lv13 パンダ
  'monkey', // Lv14 さる
  'deer', // Lv15 しか
  'horse', // Lv16 うま
  'cow', // Lv17 うし
  'tiger', // Lv18 とら
  'lion', // Lv19 ライオン
  'elephant', // Lv20 ぞう
];

/// 成長段階。値はそのままアセットの添字(s0..s4)に対応する。
enum GrowthStage { baby, child, young, adult, master }

/// 段階の表示名（暫定・日本語）。TODO: l10n 対応。
const List<String> growthStageNames = [
  'あかちゃん',
  'こども',
  'わかもの',
  'おとな',
  'はかせ',
];

String growthStageName(GrowthStage stage) => growthStageNames[stage.index];

/// 各段階に到達するために必要な累積EXPのしきい値（index = 段階）。
const List<int> growthStageThresholds = [0, 30, 90, 200, 400];

/// EXP計算のパラメータ（調整可）。
const int _clearBonus = 10; // クリアしただけで入る基礎EXP
const int _speedGold = 20; // 目標×0.6 以内
const int _speedSilver = 12; // 目標×1.0 以内
const int _speedBronze = 6; // 目標×1.5 以内
const int _speedBase = 2; // それ以外

/// レベル(0始まり)ごとの目標クリア秒。上位レベルほど難しいので長め。
double levelTargetSeconds(int level) => 6 + level * 1.5;

/// 経験値の最大値（はかせ到達後も内部的には貯まるが、表示上はここで頭打ち）。
const int maxExp = 999;

/// 指定レベルの動物キーを返す。範囲外は末尾にクランプ。
String animalForLevel(int level) =>
    growthAnimals[level.clamp(0, growthAnimals.length - 1)];

/// 指定レベル・段階のSVGアセットパス。
String growthAssetPath(int level, int stage) {
  final s = stage.clamp(0, GrowthStage.values.length - 1);
  return 'assets/images/growth/${animalForLevel(level)}_s$s.svg';
}

/// 累積EXPから現在の成長段階を求める。
GrowthStage stageForExp(int exp) {
  var stage = GrowthStage.baby;
  for (var i = 0; i < growthStageThresholds.length; i++) {
    if (exp >= growthStageThresholds[i]) stage = GrowthStage.values[i];
  }
  return stage;
}

/// 1回のクリアで得るEXP。speed が速い（target比が小さい）ほど多い。
int gainedExp({required int level, required Duration time}) {
  final target = levelTargetSeconds(level);
  final seconds = time.inMilliseconds / 1000.0;
  final int speed;
  if (seconds <= target * 0.6) {
    speed = _speedGold;
  } else if (seconds <= target) {
    speed = _speedSilver;
  } else if (seconds <= target * 1.5) {
    speed = _speedBronze;
  } else {
    speed = _speedBase;
  }
  return _clearBonus + speed;
}

/// 現在の段階の開始EXP（バーの下限）。
int stageFloorExp(int exp) => growthStageThresholds[stageForExp(exp).index];

/// 次の段階に必要なEXP（最終段階なら null）。
int? nextStageExp(int exp) {
  final i = stageForExp(exp).index;
  if (i + 1 >= growthStageThresholds.length) return null;
  return growthStageThresholds[i + 1];
}

/// 現在の段階内での進捗(0.0〜1.0)。最終段階は常に1.0。
double stageProgress(int exp) {
  final floor = stageFloorExp(exp);
  final next = nextStageExp(exp);
  if (next == null) return 1.0;
  return ((exp - floor) / (next - floor)).clamp(0.0, 1.0);
}

/// 最終段階（はかせ）かどうか。
bool isMaster(int exp) => stageForExp(exp) == GrowthStage.master;

/// レコード追加時のEXP加算結果。リザルト画面の演出に使う。
class GrowthGain {
  final int gainedExp;
  final int totalExp;
  final GrowthStage before;
  final GrowthStage after;

  const GrowthGain({
    required this.gainedExp,
    required this.totalExp,
    required this.before,
    required this.after,
  });

  bool get leveledUp => after.index > before.index;
}

/// EXP値を [0, maxExp] に収める。
int clampExp(int exp) => max(0, min(exp, maxExp));
