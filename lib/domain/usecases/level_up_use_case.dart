import 'dart:math';

class LevelUpResult {
  final int newLevel;
  final int newXp;
  final int newAppearanceStage;
  final bool leveledUp;

  const LevelUpResult({
    required this.newLevel,
    required this.newXp,
    required this.newAppearanceStage,
    required this.leveledUp,
  });
}

class LevelUpParams {
  final int currentLevel;
  final int currentXp;
  final int xpGained;

  const LevelUpParams({
    required this.currentLevel,
    required this.currentXp,
    required this.xpGained,
  });
}

class LevelUpUseCase {
  LevelUpResult execute(LevelUpParams params) {
    int level = params.currentLevel;
    int xp = params.currentXp + params.xpGained;
    bool leveledUp = false;

    while (true) {
      final xpNeeded = (100 * pow(level, 1.3)).round();
      if (xp >= xpNeeded) {
        xp -= xpNeeded;
        level++;
        leveledUp = true;
      } else {
        break;
      }
    }

    // appearance_stage (1-5), rises every 5 levels
    int appearanceStage = 1 + ((level - 1) ~/ 5);
    if (appearanceStage > 5) {
      appearanceStage = 5;
    }

    return LevelUpResult(
      newLevel: level,
      newXp: xp,
      newAppearanceStage: appearanceStage,
      leveledUp: leveledUp,
    );
  }
}
