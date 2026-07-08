import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/level_up_use_case.dart';
import '../datasources/local/sqlite_task_datasource.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final SqliteTaskDatasource _sqliteTaskDatasource;
  final SupabaseRemoteDatasource _supabaseRemoteDatasource;

  TaskRepositoryImpl(
    this._sqliteTaskDatasource,
    this._supabaseRemoteDatasource,
  );

  @override
  Future<void> createTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task.copyWith(isSynced: false));

    // Save to SQLite locally first (offline-first)
    await _sqliteTaskDatasource.insertTask(taskModel);

    // Try to sync to Supabase — failures are intentionally swallowed.
    // Task is already saved locally and will sync on next attempt.
    try {
      await _syncSingleTaskToRemote(taskModel);
    } catch (_) {
      // Offline-first: ignore all sync errors
    }
  }

  @override
  Future<List<Task>> getTasks(String userId) async {
    // Cast to List<Task> explicitly so the runtime list type is List<Task>,
    // not List<TaskModel> — prevents type errors on subsequent inserts.
    final models = await _sqliteTaskDatasource.getTasks(userId);
    return List<Task>.from(models);
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    return await _sqliteTaskDatasource.getTaskById(taskId);
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task.copyWith(isSynced: false));

    // Update SQLite locally first (offline-first)
    await _sqliteTaskDatasource.updateTask(taskModel);

    // Try to sync to Supabase — failures are intentionally swallowed.
    try {
      await _syncSingleTaskToRemote(taskModel);
    } catch (_) {
      // Offline-first: ignore all sync errors
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // Delete from local SQLite first (offline-first)
    await _sqliteTaskDatasource.deleteTask(taskId);

    // Try to delete from Supabase — failures are intentionally swallowed.
    try {
      await _supabaseRemoteDatasource.deleteTask(taskId);
    } catch (_) {
      // Offline-first: ignore all sync errors
    }
  }

  @override
  Future<void> syncTasks(String userId) async {
    // 1. Push all unsynced local tasks to remote Supabase
    final unsyncedTasks = await _sqliteTaskDatasource.getUnsyncedTasks(userId);
    for (final task in unsyncedTasks) {
      await _syncSingleTaskToRemote(task);
    }

    // 2. Pull remote tasks from Supabase and cache/save to local SQLite
    final remoteTasksData = await _supabaseRemoteDatasource.getTasks(userId);
    for (final data in remoteTasksData) {
      final remoteTask = TaskModel.fromMap(data).copyWith(isSynced: true);
      await _sqliteTaskDatasource.insertTask(TaskModel.fromEntity(remoteTask));
    }
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final rawTasks = await _supabaseRemoteDatasource.getAllTasks();
    // Explicitly type as <Task> so the runtime list is List<Task>,
    // not List<TaskModel> — prevents type errors when inserting Task objects.
    return rawTasks.map<Task>((map) => TaskModel.fromMap(map)).toList();
  }

  @override
  Future<List<Task>> getSubmittedTasks() async {
    final rawTasks = await _supabaseRemoteDatasource.getSubmittedTasks();
    return rawTasks.map<Task>((map) => TaskModel.fromMap(map)).toList();
  }

  @override
  Future<void> approveTask(
    String taskId,
    String studentUserId,
    int xpReward,
  ) async {
    // 1. Approve task status in remote DB
    await _supabaseRemoteDatasource.updateTaskStatus(
      taskId,
      'completed',
      DateTime.now().toIso8601String(),
    );

    // 2. Fetch student character and update level/XP
    final charData = await _supabaseRemoteDatasource.getCharacterByUserId(
      studentUserId,
    );
    if (charData != null) {
      final currentLevel = charData['level'] as int? ?? 1;
      final currentXp = charData['current_xp'] as int? ?? 0;

      final levelUpResult = LevelUpUseCase().execute(
        LevelUpParams(
          currentLevel: currentLevel,
          currentXp: currentXp,
          xpGained: xpReward,
        ),
      );

      final updatedChar = Map<String, dynamic>.from(charData);
      updatedChar['level'] = levelUpResult.newLevel;
      updatedChar['current_xp'] = levelUpResult.newXp;
      updatedChar['appearance_stage'] = levelUpResult.newAppearanceStage;
      updatedChar['updated_at'] = DateTime.now().toIso8601String();

      await _supabaseRemoteDatasource.upsertCharacter(updatedChar);
    }

    // 3. Log XP gain
    final xpLogId = const Uuid().v4();
    final xpLogData = {
      'id': xpLogId,
      'user_id': studentUserId,
      'task_id': taskId,
      'xp_amount': xpReward,
      'reason': 'task_completed',
      'created_at': DateTime.now().toIso8601String(),
    };
    await _supabaseRemoteDatasource.insertXpLog(xpLogData);
  }

  @override
  Future<void> rejectTask(String taskId) async {
    await _supabaseRemoteDatasource.updateTaskStatus(
      taskId,
      'in_progress',
      null,
    );
  }

  Future<void> _syncSingleTaskToRemote(TaskModel taskModel) async {
    final localPath = taskModel.proofPhotoPath;
    final uploadMap = taskModel.toSupabaseMap();

    if (localPath != null &&
        !localPath.startsWith('http') &&
        File(localPath).existsSync()) {
      final fileExtension = localPath.split('.').last;
      final fileName = '${taskModel.id}_proof.$fileExtension';
      final publicUrl = await _supabaseRemoteDatasource.uploadTaskProof(
        localPath,
        fileName,
      );
      uploadMap['proof_photo_path'] = publicUrl;
    }

    await _supabaseRemoteDatasource.upsertTask(uploadMap);
    await _sqliteTaskDatasource.markAsSynced(taskModel.id);
  }
}
