import 'package:sqflite/sqflite.dart';
import '../../models/xp_log_model.dart';
import 'sqlite_helper.dart';

class SqliteXpLogDatasource {
  final SqliteHelper _sqliteHelper;

  SqliteXpLogDatasource(this._sqliteHelper);

  Future<void> insertXpLog(XpLogModel log) async {
    final db = await _sqliteHelper.database;
    await db.insert(SqliteHelper.tableXpLogs, {
      ...log.toMap(),
      'is_synced': 0, // Set unsynced initially
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<XpLogModel>> getXpLogs(String userId) async {
    final db = await _sqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      SqliteHelper.tableXpLogs,
      where: 'user_id = ?',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => XpLogModel.fromMap(map)).toList();
  }

  Future<List<XpLogModel>> getUnsyncedXpLogs(String userId) async {
    final db = await _sqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      SqliteHelper.tableXpLogs,
      where: 'user_id = ? AND is_synced = ?',
      whereArgs: [userId, 0],
    );
    return maps.map((map) => XpLogModel.fromMap(map)).toList();
  }

  Future<void> markAsSynced(String logId) async {
    final db = await _sqliteHelper.database;
    await db.update(
      SqliteHelper.tableXpLogs,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [logId],
    );
  }
}
