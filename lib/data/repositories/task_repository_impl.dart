import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
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
          (a) => a.studentId.toLowerCase() == userId.toLowerCase(),
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
      final List<TaskAssignment> updatedAssignments = List.from(
        existingTask.assignments!,
      );
      final myAssignmentIndex = updatedAssignments.indexWhere(
        (a) => a.studentId.toLowerCase() == task.userId.toLowerCase(),
      );
      if (myAssignmentIndex != -1) {
        updatedAssignments[myAssignmentIndex] =
            updatedAssignments[myAssignmentIndex].copyWith(
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

    final taskModel = TaskModel.fromEntity(
      updatedTask.copyWith(isSynced: false),
    );

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
    try {
      debugPrint('=== STARTING SYNC FOR USER: $userId ===');
      final unsyncedTasks = await _sqliteTaskDatasource.getUnsyncedTasks();
      debugPrint('Found ${unsyncedTasks.length} unsynced local tasks');
      for (final task in unsyncedTasks) {
        debugPrint('Syncing local task to remote: ${task.id}, title: ${task.title}');
        await _syncSingleTaskToRemote(task);
      }

      final remoteTasksData = await _supabaseRemoteDatasource.getTasks(userId);
      debugPrint('Retrieved ${remoteTasksData.length} tasks from remote Supabase');
      for (final data in remoteTasksData) {
        final remoteTask = TaskModel.fromMap(data).copyWith(isSynced: true);
        debugPrint(
          'Caching remote task to SQLite: ${remoteTask.id}, title: ${remoteTask.title}',
        );
        await _sqliteTaskDatasource.insertTask(
          TaskModel.fromEntity(remoteTask),
        );
      }
      debugPrint('=== SYNC COMPLETED SUCCESSFULLY ===');
    } catch (e, stack) {
      debugPrint('=== SYNC FAILED ===');
      debugPrint('Error during sync: $e');
      debugPrint('Stacktrace: $stack');
      rethrow;
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
          expandedTasks.add(
            task.copyWith(
              userId: assignment.studentId,
              status: assignment.status,
              proofPhotoPath: assignment.proofPhotoPath,
              completedAt: assignment.completedAt,
              studentUsername: assignment.studentUsername,
            ),
          );
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
            expandedTasks.add(
              task.copyWith(
                userId: assignment.studentId,
                status: assignment.status,
                proofPhotoPath: assignment.proofPhotoPath,
                completedAt: assignment.completedAt,
                studentUsername: assignment.studentUsername,
              ),
            );
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
  Future<void> approveTask(String taskId, String studentUserId) async {
    debugPrint(
      '=== APPROVE TASK START: taskId=$taskId, studentId=$studentUserId ===',
    );

    // Update task/assignment status to completed in Supabase
    final rawTasks = await _supabaseRemoteDatasource.getAllTasks();
    final map = rawTasks.firstWhere((m) => m['id'] == taskId);
    final task = TaskModel.fromMap(map);

    if (task.assignments != null) {
      final List<TaskAssignment> updatedAssignments = List.from(
        task.assignments!,
      );
      final myAssignmentIndex = updatedAssignments.indexWhere(
        (a) => a.studentId.toLowerCase() == studentUserId.toLowerCase(),
      );
      if (myAssignmentIndex != -1) {
        // Preserve the original completedAt if already recorded by the student,
        // only fall back to now() if it was never set.
        final existingCompletedAt =
            updatedAssignments[myAssignmentIndex].completedAt;
        updatedAssignments[myAssignmentIndex] =
            updatedAssignments[myAssignmentIndex].copyWith(
              status: 'completed',
              completedAt: existingCompletedAt ?? DateTime.now(),
            );

        final updatedTask = task.copyWith(assignments: updatedAssignments);
        await _supabaseRemoteDatasource.upsertTask(
          TaskModel.fromEntity(updatedTask).toSupabaseMap(),
        );
        debugPrint(
          'Task assignment status updated to completed for student: $studentUserId',
        );
      } else {
        debugPrint('WARNING: No assignment found for studentId: $studentUserId');
      }
    } else {
      final existingCompletedAt = task.completedAt;
      await _supabaseRemoteDatasource.updateTaskStatus(
        taskId,
        'completed',
        (existingCompletedAt ?? DateTime.now()).toIso8601String(),
      );
      debugPrint('Task status updated to completed (no assignments)');
    }

    debugPrint('=== APPROVE TASK COMPLETE (status updated) ===');
  }

  @override
  Future<void> rejectTask(String taskId, String studentUserId) async {
    final rawTasks = await _supabaseRemoteDatasource.getAllTasks();
    final map = rawTasks.firstWhere((m) => m['id'] == taskId);
    final task = TaskModel.fromMap(map);

    if (task.assignments != null) {
      final List<TaskAssignment> updatedAssignments = List.from(
        task.assignments!,
      );
      final myAssignmentIndex = updatedAssignments.indexWhere(
        (a) => a.studentId.toLowerCase() == studentUserId.toLowerCase(),
      );
      if (myAssignmentIndex != -1) {
        updatedAssignments[myAssignmentIndex] =
            updatedAssignments[myAssignmentIndex].copyWith(
              status: 'pending',
              completedAt: null,
              proofPhotoPath: null,
            );

        final updatedTask = task.copyWith(assignments: updatedAssignments);
        await _supabaseRemoteDatasource.upsertTask(
          TaskModel.fromEntity(updatedTask).toSupabaseMap(),
        );
      }
    } else {
      await _supabaseRemoteDatasource.updateTaskStatus(taskId, 'pending', null);
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
            final fileName =
                '${taskModel.id}_${assignment.studentId}_proof.$fileExtension';
            final publicUrl = await _supabaseRemoteDatasource.uploadTaskProof(
              assLocalPath,
              fileName,
            );
            updatedAssignments[i] = assignment.copyWith(
              proofPhotoPath: publicUrl,
            );
            assignmentsChanged = true;
          } catch (_) {
            // Swallowed
          }
        }
      }
      if (assignmentsChanged) {
        uploadMap['assignments'] = updatedAssignments
            .map((e) => e.toMap())
            .toList();
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
      await _sqliteTaskDatasource.insertTask(
        TaskModel.fromEntity(updatedLocalTask),
      );
    }
  }
}
