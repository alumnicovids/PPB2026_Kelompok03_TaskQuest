import 'dart:io';
import 'dart:math';
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
    final models = await _sqliteTaskDatasource.getTasks(userId);
    return models.map<Task>((task) {
      if (task.assignments != null) {
        final myAssignment = task.assignments!.firstWhere(
          (a) => a.studentId == userId,
          orElse: () => TaskAssignment(
            studentId: userId,
            studentUsername: task.studentUsername ?? '',
            status: task.status,
            proofPhotoPath: task.proofPhotoPath,
            completedAt: task.completedAt,
          ),
        );
        return task.copyWith(
          userId: userId,
          status: myAssignment.status,
          proofPhotoPath: myAssignment.proofPhotoPath,
          completedAt: myAssignment.completedAt,
          studentUsername: myAssignment.studentUsername,
        );
      }
      return task;
    }).toList();
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    return await _sqliteTaskDatasource.getTaskById(taskId);
  }

  @override
  Future<void> updateTask(Task task) async {
    final existingTask = await _sqliteTaskDatasource.getTaskById(task.id);
    Task updatedTask = task;

    if (existingTask != null && existingTask.assignments != null) {
      final List<TaskAssignment> updatedAssignments = List.from(existingTask.assignments!);
      final myAssignmentIndex = updatedAssignments.indexWhere((a) => a.studentId == task.userId);
      if (myAssignmentIndex != -1) {
        updatedAssignments[myAssignmentIndex] = updatedAssignments[myAssignmentIndex].copyWith(
          status: task.status,
          proofPhotoPath: task.proofPhotoPath,
          completedAt: task.completedAt,
        );
        updatedTask = existingTask.copyWith(
          assignments: updatedAssignments,
          isSynced: false,
        );
      }
    }

    final taskModel = TaskModel.fromEntity(updatedTask.copyWith(isSynced: false));

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
    final unsyncedTasks = await _sqliteTaskDatasource.getUnsyncedTasks();
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
    final List<Task> expandedTasks = [];
    for (final map in rawTasks) {
      final task = TaskModel.fromMap(map);
      if (task.assignments != null && task.assignments!.isNotEmpty) {
        for (final assignment in task.assignments!) {
          expandedTasks.add(task.copyWith(
            userId: assignment.studentId,
            status: assignment.status,
            proofPhotoPath: assignment.proofPhotoPath,
            completedAt: assignment.completedAt,
            studentUsername: assignment.studentUsername,
          ));
        }
      } else {
        expandedTasks.add(task);
      }
    }
    return expandedTasks;
  }

  @override
  Future<List<Task>> getSubmittedTasks() async {
    final rawTasks = await _supabaseRemoteDatasource.getAllTasks();
    final List<Task> expandedTasks = [];
    for (final map in rawTasks) {
      final task = TaskModel.fromMap(map);
      if (task.assignments != null && task.assignments!.isNotEmpty) {
        for (final assignment in task.assignments!) {
          if (assignment.status == 'submitted') {
            expandedTasks.add(task.copyWith(
              userId: assignment.studentId,
              status: assignment.status,
              proofPhotoPath: assignment.proofPhotoPath,
              completedAt: assignment.completedAt,
              studentUsername: assignment.studentUsername,
            ));
          }
        }
      } else {
        if (task.status == 'submitted') {
          expandedTasks.add(task);
        }
      }
    }
    return expandedTasks;
  }

  @override
  Future<void> approveTask(
    String taskId,
    String studentUserId,
    int xpReward,
  ) async {
    // 1. Approve task status in remote DB
    final rawTasks = await _supabaseRemoteDatasource.getAllTasks();
    final map = rawTasks.firstWhere((m) => m['id'] == taskId);
    final task = TaskModel.fromMap(map);

    if (task.assignments != null) {
      final List<TaskAssignment> updatedAssignments = List.from(task.assignments!);
      final myAssignmentIndex = updatedAssignments.indexWhere((a) => a.studentId == studentUserId);
      if (myAssignmentIndex != -1) {
        updatedAssignments[myAssignmentIndex] = updatedAssignments[myAssignmentIndex].copyWith(
          status: 'completed',
          completedAt: DateTime.now(),
        );

        final updatedTask = task.copyWith(assignments: updatedAssignments);
        await _supabaseRemoteDatasource.upsertTask(TaskModel.fromEntity(updatedTask).toSupabaseMap());
      }
    } else {
      await _supabaseRemoteDatasource.updateTaskStatus(
        taskId,
        'completed',
        DateTime.now().toIso8601String(),
      );
    }

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
      
      final xpToNext = (100 * pow(levelUpResult.newLevel, 1.3)).round();
      updatedChar['xp_to_next_level'] = xpToNext;

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
  Future<void> rejectTask(String taskId, String studentUserId) async {
    final rawTasks = await _supabaseRemoteDatasource.getAllTasks();
    final map = rawTasks.firstWhere((m) => m['id'] == taskId);
    final task = TaskModel.fromMap(map);

    if (task.assignments != null) {
      final List<TaskAssignment> updatedAssignments = List.from(task.assignments!);
      final myAssignmentIndex = updatedAssignments.indexWhere((a) => a.studentId == studentUserId);
      if (myAssignmentIndex != -1) {
        updatedAssignments[myAssignmentIndex] = updatedAssignments[myAssignmentIndex].copyWith(
          status: 'pending',
          completedAt: null,
          proofPhotoPath: null,
        );

        final updatedTask = task.copyWith(assignments: updatedAssignments);
        await _supabaseRemoteDatasource.upsertTask(TaskModel.fromEntity(updatedTask).toSupabaseMap());
      }
    } else {
      await _supabaseRemoteDatasource.updateTaskStatus(
        taskId,
        'pending',
        null,
      );
    }
  }

  Future<void> _syncSingleTaskToRemote(TaskModel taskModel) async {
    final uploadMap = taskModel.toSupabaseMap();
    List<TaskAssignment>? updatedAssignments = taskModel.assignments != null 
        ? List.from(taskModel.assignments!) 
        : null;

    final rootLocalPath = taskModel.proofPhotoPath;
    String? rootPublicUrl;
    if (rootLocalPath != null &&
        !rootLocalPath.startsWith('http') &&
        File(rootLocalPath).existsSync()) {
      try {
        final fileExtension = rootLocalPath.split('.').last;
        final fileName = '${taskModel.id}_proof.$fileExtension';
        rootPublicUrl = await _supabaseRemoteDatasource.uploadTaskProof(
          rootLocalPath,
          fileName,
        );
        uploadMap['proof_photo_path'] = rootPublicUrl;
      } catch (_) {
        // Swallowed
      }
    }

    if (updatedAssignments != null) {
      bool assignmentsChanged = false;
      for (int i = 0; i < updatedAssignments.length; i++) {
        final assignment = updatedAssignments[i];
        final assLocalPath = assignment.proofPhotoPath;
        if (assLocalPath != null &&
            !assLocalPath.startsWith('http') &&
            File(assLocalPath).existsSync()) {
          try {
            final fileExtension = assLocalPath.split('.').last;
            final fileName = '${taskModel.id}_${assignment.studentId}_proof.$fileExtension';
            final publicUrl = await _supabaseRemoteDatasource.uploadTaskProof(
              assLocalPath,
              fileName,
            );
            updatedAssignments[i] = assignment.copyWith(proofPhotoPath: publicUrl);
            assignmentsChanged = true;
          } catch (_) {
            // Swallowed
          }
        }
      }
      if (assignmentsChanged) {
        uploadMap['assignments'] = updatedAssignments.map((e) => e.toMap()).toList();
      }
    }

    await _supabaseRemoteDatasource.upsertTask(uploadMap);
    await _sqliteTaskDatasource.markAsSynced(taskModel.id);

    if (rootPublicUrl != null || updatedAssignments != null) {
      final updatedLocalTask = taskModel.copyWith(
        proofPhotoPath: rootPublicUrl ?? taskModel.proofPhotoPath,
        assignments: updatedAssignments ?? taskModel.assignments,
        isSynced: true,
      );
      await _sqliteTaskDatasource.insertTask(TaskModel.fromEntity(updatedLocalTask));
    }
  }
}
