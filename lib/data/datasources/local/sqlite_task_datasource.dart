import 'package:sqflite/sqflite.dart';
import '../../models/task_model.dart';
import 'sqlite_helper.dart';

class SqliteTaskDatasource {
  final SqliteHelper _sqliteHelper;

  SqliteTaskDatasource(this._sqliteHelper);

  Future<void> insertTask(TaskModel task) async {
    final db = await _sqliteHelper.database;
    await db.insert(
      SqliteHelper.tableTasks,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TaskModel>> getTasks(String userId) async {
    final db = await _sqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      SqliteHelper.tableTasks,
      where: 'user_id = ? OR assignments LIKE ?',
      whereArgs: [userId, '%"student_id":"$userId"%'],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    final db = await _sqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      SqliteHelper.tableTasks,
      where: 'id = ?',
      whereArgs: [taskId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return TaskModel.fromMap(maps.first);
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await _sqliteHelper.database;
    await db.update(
      SqliteHelper.tableTasks,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String taskId) async {
    final db = await _sqliteHelper.database;
    await db.delete(
      SqliteHelper.tableTasks,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<List<TaskModel>> getUnsyncedTasks() async {
    final db = await _sqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      SqliteHelper.tableTasks,
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<void> markAsSynced(String taskId) async {
    final db = await _sqliteHelper.database;
    await db.update(
      SqliteHelper.tableTasks,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }
}
