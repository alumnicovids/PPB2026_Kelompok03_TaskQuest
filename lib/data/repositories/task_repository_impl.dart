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

    // Save to SQLite locally first
    await _sqliteTaskDatasource.insertTask(taskModel);

    // Try to sync to Supabase remote database
    try {
      await _supabaseRemoteDatasource.upsertTask(taskModel.toSupabaseMap());
      await _sqliteTaskDatasource.markAsSynced(task.id);
    } catch (_) {
      // Offline-first: ignore connection errors, task is saved locally
    }
  }

  @override
  Future<List<Task>> getTasks(String userId) async {
    // Return offline-first local tasks
    return await _sqliteTaskDatasource.getTasks(userId);
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    return await _sqliteTaskDatasource.getTaskById(taskId);
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task.copyWith(isSynced: false));

    // Update SQLite locally first
    await _sqliteTaskDatasource.updateTask(taskModel);

    // Try to sync to Supabase remote database
    try {
      await _supabaseRemoteDatasource.upsertTask(taskModel.toSupabaseMap());
      await _sqliteTaskDatasource.markAsSynced(task.id);
    } catch (_) {
      // Offline-first: ignore connection errors, task remains unsynced
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // Delete from local SQLite
    await _sqliteTaskDatasource.deleteTask(taskId);

    // Try to delete from Supabase remote database
    try {
      await _supabaseRemoteDatasource.deleteTask(taskId);
    } catch (_) {
      // Offline-first: ignore connection errors
    }
  }

  @override
  Future<void> syncTasks(String userId) async {
    // 1. Push all unsynced local tasks to remote Supabase
    final unsyncedTasks = await _sqliteTaskDatasource.getUnsyncedTasks(userId);
    for (final task in unsyncedTasks) {
      await _supabaseRemoteDatasource.upsertTask(task.toSupabaseMap());
      await _sqliteTaskDatasource.markAsSynced(task.id);
    }

    // 2. Pull remote tasks from Supabase and cache/save to local SQLite
    final remoteTasksData = await _supabaseRemoteDatasource.getTasks(userId);
    for (final data in remoteTasksData) {
      final remoteTask = TaskModel.fromMap(data).copyWith(isSynced: true);
      await _sqliteTaskDatasource.insertTask(TaskModel.fromEntity(remoteTask));
    }
  }
}
