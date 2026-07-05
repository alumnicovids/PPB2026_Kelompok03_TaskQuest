import 'package:flutter_test/flutter_test.dart';
import 'package:taskquest/domain/usecases/level_up_use_case.dart';

void main() {
  late LevelUpUseCase useCase;

  setUp(() {
    useCase = LevelUpUseCase();
  });

  group('LevelUpUseCase Tests', () {
    test('does not level up if gained XP is not enough', () {
      final result = useCase.execute(
        const LevelUpParams(currentLevel: 1, currentXp: 30, xpGained: 50),
      );
      expect(result.newLevel, equals(1));
      expect(result.newXp, equals(80));
      expect(result.leveledUp, isFalse);
      expect(result.newAppearanceStage, equals(1));
    });

    test('levels up once when XP exceeds threshold', () {
      // Level 1 needs 100 XP. Current: 30, Gained: 80 -> Total: 110.
      // After level up: newLevel = 2, newXp = 110 - 100 = 10.
      final result = useCase.execute(
        const LevelUpParams(currentLevel: 1, currentXp: 30, xpGained: 80),
      );
      expect(result.newLevel, equals(2));
      expect(result.newXp, equals(10));
      expect(result.leveledUp, isTrue);
      expect(result.newAppearanceStage, equals(1));
    });

    test('levels up multiple times if huge XP is gained', () {
      // Level 1: needs 100 XP
      // Level 2: needs 246 XP (100 * 2^1.3)
      // Total needed from lvl 1 to 3: 100 + 246 = 346 XP.
      // Gained: 400.
      // After level 1 -> 2: XP = 400 - 100 = 300.
      // After level 2 -> 3: XP = 300 - 246 = 54.
      final result = useCase.execute(
        const LevelUpParams(currentLevel: 1, currentXp: 0, xpGained: 400),
      );
      expect(result.newLevel, equals(3));
      expect(result.newXp, equals(54));
      expect(result.leveledUp, isTrue);
      expect(result.newAppearanceStage, equals(1));
    });

    test('calculates correct appearance stage based on level', () {
      // Level 1-5 is Stage 1
      var result = useCase.execute(
        const LevelUpParams(currentLevel: 5, currentXp: 0, xpGained: 0),
      );
      expect(result.newAppearanceStage, equals(1));

      // Level 6 is Stage 2
      result = useCase.execute(
        const LevelUpParams(currentLevel: 6, currentXp: 0, xpGained: 0),
      );
      expect(result.newAppearanceStage, equals(2));

      // Level 11 is Stage 3
      result = useCase.execute(
        const LevelUpParams(currentLevel: 11, currentXp: 0, xpGained: 0),
      );
      expect(result.newAppearanceStage, equals(3));

      // Level 25 is Stage 5 (max)
      result = useCase.execute(
        const LevelUpParams(currentLevel: 25, currentXp: 0, xpGained: 0),
      );
      expect(result.newAppearanceStage, equals(5));
    });
  });
}
