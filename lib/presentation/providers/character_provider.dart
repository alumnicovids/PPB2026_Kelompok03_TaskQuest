import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/calculate_xp_use_case.dart';
import '../../domain/usecases/level_up_use_case.dart';

class CharacterProvider with ChangeNotifier {
  final CalculateXpUseCase _calculateXpUseCase;
  final LevelUpUseCase _levelUpUseCase;

  Character? _character;
  bool _isLoading = false;

  CharacterProvider(this._calculateXpUseCase, this._levelUpUseCase);

  Character? get character => _character;
  bool get isLoading => _isLoading;

  void loadMockCharacter(String userId) {
    _character = Character(
      id: 'mock-char-id',
      userId: userId,
      classType: 'knight',
      level: 1,
      currentXp: 35,
      xpToNextLevel: 100,
      appearanceStage: 1,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  Future<Map<String, dynamic>> completeTask(
    Task task,
    DateTime completedAt,
  ) async {
    if (_character == null) return {'xpGained': 0, 'leveledUp': false};

    _isLoading = true;
    notifyListeners();

    // 1. Calculate XP reward
    final xpGained = _calculateXpUseCase.execute(
      priority: task.priority,
      deadline: task.deadline,
      completedAt: completedAt,
    );

    // 2. Perform Level Up logic
    final levelUpResult = _levelUpUseCase.execute(
      LevelUpParams(
        currentLevel: _character!.level,
        currentXp: _character!.currentXp,
        xpGained: xpGained,
      ),
    );

    final xpToNext = (100 * pow(levelUpResult.newLevel, 1.3)).round();

    _character = _character!.copyWith(
      level: levelUpResult.newLevel,
      currentXp: levelUpResult.newXp,
      xpToNextLevel: xpToNext,
      appearanceStage: levelUpResult.newAppearanceStage,
      updatedAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();

    return {'xpGained': xpGained, 'leveledUp': levelUpResult.leveledUp};
  }
}
