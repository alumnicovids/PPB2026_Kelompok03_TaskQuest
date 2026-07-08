import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/xp_log.dart';
import '../../domain/repositories/character_repository.dart';
import '../../domain/repositories/xp_log_repository.dart';
import '../../domain/usecases/calculate_xp_use_case.dart';
import '../../domain/usecases/level_up_use_case.dart';

class CharacterProvider with ChangeNotifier {
  final CalculateXpUseCase _calculateXpUseCase;
  final LevelUpUseCase _levelUpUseCase;
  final CharacterRepository _characterRepository;
  final XpLogRepository _xpLogRepository;

  Character? _character;
  bool _isLoading = false;

  CharacterProvider(
    this._calculateXpUseCase,
    this._levelUpUseCase,
    this._characterRepository,
    this._xpLogRepository,
  );

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

  Future<void> loadCharacter(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final char = await _characterRepository.getCharacter(userId);
      if (char != null) {
        _character = char;
      } else {
        // Initialize new character for user
        final newChar = Character(
          id: 'char-$userId',
          userId: userId,
          classType: 'knight',
          level: 1,
          currentXp: 0,
          xpToNextLevel: 100,
          appearanceStage: 1,
          updatedAt: DateTime.now(),
        );
        await _characterRepository.saveCharacter(newChar);
        _character = newChar;
      }
    } catch (_) {
      if (_character == null) {
        loadMockCharacter(userId);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

    final updatedChar = _character!.copyWith(
      level: levelUpResult.newLevel,
      currentXp: levelUpResult.newXp,
      xpToNextLevel: xpToNext,
      appearanceStage: levelUpResult.newAppearanceStage,
      updatedAt: DateTime.now(),
    );

    // Save changes using repository
    await _characterRepository.saveCharacter(updatedChar);
    _character = updatedChar;

    // Create and save XP Log
    final xpLog = XpLog(
      id: const Uuid().v4(),
      userId: _character!.userId,
      taskId: task.id,
      xpAmount: xpGained,
      reason: 'task_completed: ${task.title}',
      createdAt: DateTime.now(),
    );
    await _xpLogRepository.saveXpLog(xpLog);

    _isLoading = false;
    notifyListeners();

    return {'xpGained': xpGained, 'leveledUp': levelUpResult.leveledUp};
  }
}
