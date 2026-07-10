import 'dart:math';
import '../entities/task.dart';
import '../entities/character.dart';
import '../entities/xp_log.dart';
import '../repositories/task_repository.dart';
import '../repositories/character_repository.dart';
import '../repositories/xp_log_repository.dart';
import 'calculate_xp_use_case.dart';
import 'level_up_use_case.dart';
import 'package:uuid/uuid.dart';

class ApproveTaskParams {
  final String taskId;
  final String studentUserId;

  const ApproveTaskParams({required this.taskId, required this.studentUserId});
}

class ApproveTaskUseCase {
  final TaskRepository _taskRepository;
  final CharacterRepository _characterRepository;
  final XpLogRepository _xpLogRepository;
  final CalculateXpUseCase _calculateXpUseCase;
  final LevelUpUseCase _levelUpUseCase;

  ApproveTaskUseCase({
    required TaskRepository taskRepository,
    required CharacterRepository characterRepository,
    required XpLogRepository xpLogRepository,
    required CalculateXpUseCase calculateXpUseCase,
    required LevelUpUseCase levelUpUseCase,
  }) : _taskRepository = taskRepository,
       _characterRepository = characterRepository,
       _xpLogRepository = xpLogRepository,
       _calculateXpUseCase = calculateXpUseCase,
       _levelUpUseCase = levelUpUseCase;

  Future<void> execute(ApproveTaskParams params) async {
    // 1. Fetch task
    final task = await _taskRepository.getTaskById(params.taskId);
    if (task == null) {
      throw Exception('Task not found');
    }

    // 2. Determine completedAt time (student's submission time)
    DateTime? completedAt;
    if (task.assignments != null && task.assignments!.isNotEmpty) {
      final assignment = task.assignments!.firstWhere(
        (a) => a.studentId.toLowerCase() == params.studentUserId.toLowerCase(),
        orElse: () => throw Exception('Assignment not found for student'),
      );
      completedAt = assignment.completedAt;
    } else {
      completedAt = task.completedAt;
    }

    // Fallback if completedAt is null
    completedAt ??= DateTime.now();

    // 3. Calculate XP using CalculateXpUseCase
    final xpGained = _calculateXpUseCase.execute(
      priority: task.priority,
      deadline: task.deadline,
      completedAt: completedAt,
    );

    // 4. Update task/assignment status to completed
    if (task.assignments != null && task.assignments!.isNotEmpty) {
      final List<TaskAssignment> updatedAssignments = List.from(
        task.assignments!,
      );
      final idx = updatedAssignments.indexWhere(
        (a) => a.studentId.toLowerCase() == params.studentUserId.toLowerCase(),
      );
      if (idx != -1) {
        updatedAssignments[idx] = updatedAssignments[idx].copyWith(
          status: 'completed',
          completedAt: completedAt,
        );
      }
      final updatedTask = task.copyWith(assignments: updatedAssignments);
      await _taskRepository.updateTask(updatedTask);
    } else {
      final updatedTask = task.copyWith(
        status: 'completed',
        completedAt: completedAt,
      );
      await _taskRepository.updateTask(updatedTask);
    }

    // 5. Fetch student character and update level/XP
    var character = await _characterRepository.getCharacter(
      params.studentUserId,
    );
    if (character == null) {
      // Create a default character if none exists
      character = Character(
        id: const Uuid().v4(),
        userId: params.studentUserId,
        classType: 'knight',
        level: 1,
        currentXp: 0,
        xpToNextLevel: 100,
        appearanceStage: 1,
        updatedAt: DateTime.now(),
      );
    }

    final levelUpResult = _levelUpUseCase.execute(
      LevelUpParams(
        currentLevel: character.level,
        currentXp: character.currentXp,
        xpGained: xpGained,
      ),
    );

    final xpToNext = (100 * pow(levelUpResult.newLevel, 1.3)).round();

    final updatedChar = character.copyWith(
      level: levelUpResult.newLevel,
      currentXp: levelUpResult.newXp,
      xpToNextLevel: xpToNext,
      appearanceStage: levelUpResult.newAppearanceStage,
      updatedAt: DateTime.now(),
    );

    await _characterRepository.saveCharacter(updatedChar);

    // 6. Log XP gain
    final xpLog = XpLog(
      id: const Uuid().v4(),
      userId: params.studentUserId,
      taskId: task.id,
      xpAmount: xpGained,
      reason: 'task_completed: ${task.title}',
      createdAt: DateTime.now(),
    );
    await _xpLogRepository.saveXpLog(xpLog);
  }
}
