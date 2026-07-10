import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final SharedPreferences _sharedPreferences;

  Character? _character;
  List<Character> _allCharacters = [];
  bool _isLoading = false;
  int? _pendingLevelUpLevel;

  CharacterProvider(CharacterProviderParams params)
      : _calculateXpUseCase = params.calculateXpUseCase,
        _levelUpUseCase = params.levelUpUseCase,
        _characterRepository = params.characterRepository,
        _xpLogRepository = params.xpLogRepository,
        _sharedPreferences = params.sharedPreferences;

  Character? get character => _character;
  List<Character> get allCharacters => _allCharacters;
  bool get isLoading => _isLoading;
  int? get pendingLevelUpLevel => _pendingLevelUpLevel;

  void consumeLevelUp() {
    _pendingLevelUpLevel = null;
    notifyListeners();
  }

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
        final lastAckKey = 'last_ack_level_$userId';
        final lastAck = _sharedPreferences.getInt(lastAckKey);
        if (lastAck != null && char.level > lastAck) {
          _pendingLevelUpLevel = char.level;
        }
        await _sharedPreferences.setInt(lastAckKey, char.level);
      }
      _character = char;
    } catch (_) {
      if (_character == null) {
        loadMockCharacter(userId);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createInitialCharacter(String userId, String classType) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newChar = Character(
        id: const Uuid().v4(),
        userId: userId,
        classType: classType,
        level: 1,
        currentXp: 0,
        xpToNextLevel: 100,
        appearanceStage: 1,
        updatedAt: DateTime.now(),
      );
      await _characterRepository.saveCharacter(newChar);
      _character = newChar;

      final lastAckKey = 'last_ack_level_$userId';
      await _sharedPreferences.setInt(lastAckKey, 1);

      debugPrint(
        'Initial character created: classType=$classType for userId=$userId',
      );
    } catch (e) {
      debugPrint('ERROR creating initial character: $e');
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

    if (levelUpResult.leveledUp) {
      _pendingLevelUpLevel = levelUpResult.newLevel;
      final lastAckKey = 'last_ack_level_${_character!.userId}';
      await _sharedPreferences.setInt(lastAckKey, levelUpResult.newLevel);
    }

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

  Future<void> loadAllCharacters() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allCharacters = await _characterRepository.getAllCharacters();
    } catch (_) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCharacterDetails(Character character) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _characterRepository.saveCharacter(character);
      if (_character?.userId == character.userId) {
        _character = character;
      }
      await loadAllCharacters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadAvatarImage(String localPath, String fileName) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _characterRepository.uploadCharacterAvatar(localPath, fileName);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class CharacterProviderParams {
  final CalculateXpUseCase calculateXpUseCase;
  final LevelUpUseCase levelUpUseCase;
  final CharacterRepository characterRepository;
  final XpLogRepository xpLogRepository;
  final SharedPreferences sharedPreferences;

  const CharacterProviderParams({
    required this.calculateXpUseCase,
    required this.levelUpUseCase,
    required this.characterRepository,
    required this.xpLogRepository,
    required this.sharedPreferences,
  });
}
