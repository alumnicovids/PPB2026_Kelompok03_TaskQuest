import 'package:flutter_test/flutter_test.dart';
import 'package:taskquest/domain/entities/character.dart';
import 'package:taskquest/domain/entities/task.dart';
import 'package:taskquest/domain/entities/xp_log.dart';
import 'package:taskquest/domain/repositories/character_repository.dart';
import 'package:taskquest/domain/repositories/task_repository.dart';
import 'package:taskquest/domain/repositories/xp_log_repository.dart';
import 'package:taskquest/domain/usecases/approve_task_use_case.dart';
import 'package:taskquest/domain/usecases/calculate_xp_use_case.dart';
import 'package:taskquest/domain/usecases/level_up_use_case.dart';

class FakeTaskRepository implements TaskRepository {
  final Map<String, Task> tasks = {};
  int updateCount = 0;

  @override
  Future<void> createTask(Task task) async {
    tasks[task.id] = task;
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    return tasks[taskId];
  }

  @override
  Future<void> updateTask(Task task) async {
    tasks[task.id] = task;
    updateCount++;
  }

  @override
  Future<void> deleteTask(String taskId) async {}

  @override
  Future<List<Task>> getAllTasks() async => tasks.values.toList();

  @override
  Future<List<Task>> getSubmittedTasks() async => [];

  @override
  Future<List<Task>> getTasks(String userId) async => [];

  @override
  Future<void> syncTasks(String userId) async {}

  @override
  Future<void> approveTask(
    String taskId,
    String studentUserId,
    int xpReward,
  ) async {}

  @override
  Future<void> rejectTask(String taskId, String studentUserId) async {}
}

class FakeCharacterRepository implements CharacterRepository {
  final Map<String, Character> characters = {};
  int saveCount = 0;

  @override
  Future<Character?> getCharacter(String userId) async {
    return characters[userId];
  }

  @override
  Future<void> saveCharacter(Character character) async {
    characters[character.userId] = character;
    saveCount++;
  }

  @override
  Future<List<Character>> getAllCharacters() async =>
      characters.values.toList();

  @override
  Future<String> uploadCharacterAvatar(
    String localPath,
    String fileName,
  ) async => '';
}

class FakeXpLogRepository implements XpLogRepository {
  final List<XpLog> logs = [];

  @override
  Future<void> saveXpLog(XpLog xpLog) async {
    logs.add(xpLog);
  }

  @override
  Future<List<XpLog>> getXpLogs(String userId) async => logs;

  @override
  Future<void> syncXpLogs(String userId) async {}
}

void main() {
  late FakeTaskRepository taskRepo;
  late FakeCharacterRepository charRepo;
  late FakeXpLogRepository xpLogRepo;
  late CalculateXpUseCase calculateXpUseCase;
  late LevelUpUseCase levelUpUseCase;
  late ApproveTaskUseCase useCase;

  setUp(() {
    taskRepo = FakeTaskRepository();
    charRepo = FakeCharacterRepository();
    xpLogRepo = FakeXpLogRepository();
    calculateXpUseCase = CalculateXpUseCase();
    levelUpUseCase = LevelUpUseCase();
    useCase = ApproveTaskUseCase(
      taskRepository: taskRepo,
      characterRepository: charRepo,
      xpLogRepository: xpLogRepo,
      calculateXpUseCase: calculateXpUseCase,
      levelUpUseCase: levelUpUseCase,
    );
  });

  group('ApproveTaskUseCase Tests', () {
    test('successfully approves own student task and grants XP', () async {
      final task = Task(
        id: 'task-1',
        userId: 'student-1',
        title: 'Learn Clean Arch',
        category: 'kuliah',
        priority: 'high',
        deadline: DateTime(2026, 7, 5, 23, 59),
        status: 'submitted',
        xpReward: 35,
        completedAt: DateTime(
          2026,
          7,
          5,
          12,
          0,
        ), // Exactly on deadline day -> 1.5x
        createdAt: DateTime(2026, 7, 1),
        isSynced: true,
      );

      final character = Character(
        id: 'char-1',
        userId: 'student-1',
        classType: 'knight',
        level: 1,
        currentXp: 10,
        xpToNextLevel: 100,
        appearanceStage: 1,
        updatedAt: DateTime(2026, 7, 1),
      );

      await taskRepo.createTask(task);
      await charRepo.saveCharacter(character);

      await useCase.execute(
        const ApproveTaskParams(taskId: 'task-1', studentUserId: 'student-1'),
      );

      // Verify task status updated to completed
      final updatedTask = await taskRepo.getTaskById('task-1');
      expect(updatedTask?.status, equals('completed'));

      // Verify character received XP (35 * 1.5 = 52.5 -> 53 XP). 10 + 53 = 63 XP
      final updatedChar = await charRepo.getCharacter('student-1');
      expect(updatedChar?.currentXp, equals(63));
      expect(updatedChar?.level, equals(1));

      // Verify XP log is saved
      expect(xpLogRepo.logs.length, equals(1));
      expect(xpLogRepo.logs.first.xpAmount, equals(53));
    });

    test(
      'successfully approves lecturer assigned task and updates assignment status',
      () async {
        final task = Task(
          id: 'task-2',
          userId: 'lecturer-1',
          title: 'Homework 1',
          category: 'kuliah',
          priority: 'medium',
          deadline: DateTime(2026, 7, 5, 23, 59),
          status: 'pending',
          xpReward: 20,
          createdAt: DateTime(2026, 7, 1),
          isSynced: true,
          assignments: [
            TaskAssignment(
              studentId: 'student-1',
              studentUsername: 'student1',
              status: 'submitted',
              completedAt: DateTime(
                2026,
                7,
                3,
              ), // 2 days before deadline -> 1.2x multiplier
            ),
          ],
        );

        final character = Character(
          id: 'char-1',
          userId: 'student-1',
          classType: 'mage',
          level: 1,
          currentXp: 10,
          xpToNextLevel: 100,
          appearanceStage: 1,
          updatedAt: DateTime(2026, 7, 1),
        );

        await taskRepo.createTask(task);
        await charRepo.saveCharacter(character);

        await useCase.execute(
          const ApproveTaskParams(taskId: 'task-2', studentUserId: 'student-1'),
        );

        // Verify assignment status updated to completed
        final updatedTask = await taskRepo.getTaskById('task-2');
        expect(updatedTask?.assignments?.first.status, equals('completed'));

        // Verify character received XP (20 * 1.2 = 24 XP). 10 + 24 = 34 XP
        final updatedChar = await charRepo.getCharacter('student-1');
        expect(updatedChar?.currentXp, equals(34));

        // Verify XP log
        expect(xpLogRepo.logs.length, equals(1));
        expect(xpLogRepo.logs.first.xpAmount, equals(24));
      },
    );
  });
}
