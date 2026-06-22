import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/domain/growth.dart';

void main() {
  group('growthAnimals mapping', () {
    test('has one animal per level', () {
      expect(growthAnimals, hasLength(DefNum.maxLevel));
    });

    test('animalForLevel maps levels and clamps out-of-range', () {
      expect(animalForLevel(0), 'chick');
      expect(animalForLevel(11), 'bear');
      expect(animalForLevel(19), 'elephant');
      expect(animalForLevel(999), 'elephant');
      expect(animalForLevel(-5), 'chick');
    });

    test('growthAssetPath builds the expected svg path', () {
      expect(growthAssetPath(0, 0), 'assets/images/growth/chick_s0.svg');
      expect(growthAssetPath(11, 4), 'assets/images/growth/bear_s4.svg');
      // 段階は 0..4 にクランプされる。
      expect(growthAssetPath(0, 9), 'assets/images/growth/chick_s4.svg');
    });
  });

  group('stageForExp', () {
    test('maps cumulative exp to the right stage', () {
      expect(stageForExp(0), GrowthStage.baby);
      expect(stageForExp(29), GrowthStage.baby);
      expect(stageForExp(30), GrowthStage.child);
      expect(stageForExp(89), GrowthStage.child);
      expect(stageForExp(90), GrowthStage.young);
      expect(stageForExp(199), GrowthStage.young);
      expect(stageForExp(200), GrowthStage.adult);
      expect(stageForExp(399), GrowthStage.adult);
      expect(stageForExp(400), GrowthStage.master);
      expect(stageForExp(999), GrowthStage.master);
    });
  });

  group('gainedExp', () {
    test('faster clears earn more (level 0, target 6s)', () {
      // 完了ボーナス10 + 速度ボーナス。
      expect(gainedExp(level: 0, time: const Duration(seconds: 3)), 30); // 金
      expect(gainedExp(level: 0, time: const Duration(seconds: 5)), 22); // 銀
      expect(gainedExp(level: 0, time: const Duration(seconds: 8)), 16); // 銅
      expect(gainedExp(level: 0, time: const Duration(seconds: 20)), 12); // 参加
    });
  });

  group('stage progress', () {
    test('progress within a stage and master handling', () {
      expect(stageProgress(0), 0.0);
      expect(stageProgress(15), closeTo(0.5, 0.0001)); // baby 0..30
      expect(nextStageExp(400), isNull);
      expect(stageProgress(400), 1.0);
      expect(isMaster(400), isTrue);
      expect(isMaster(399), isFalse);
    });
  });

  group('GrowthGain', () {
    test('leveledUp reflects a stage change', () {
      const up = GrowthGain(
        gainedExp: 30,
        totalExp: 30,
        before: GrowthStage.baby,
        after: GrowthStage.child,
      );
      const flat = GrowthGain(
        gainedExp: 20,
        totalExp: 50,
        before: GrowthStage.child,
        after: GrowthStage.child,
      );
      expect(up.leveledUp, isTrue);
      expect(flat.leveledUp, isFalse);
    });
  });
}
