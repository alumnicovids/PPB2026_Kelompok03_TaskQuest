import 'package:sqflite/sqflite.dart';
import '../../models/study_location_model.dart';
import 'sqlite_helper.dart';

class SqliteLocationDatasource {
  final SqliteHelper _sqliteHelper;

  SqliteLocationDatasource(this._sqliteHelper);

  Future<void> insertLocation(StudyLocationModel location) async {
    final db = await _sqliteHelper.database;
    await db.insert(
      SqliteHelper.tableStudyLocations,
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudyLocationModel>> getLocations(String userId) async {
    final db = await _sqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      SqliteHelper.tableStudyLocations,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => StudyLocationModel.fromMap(map)).toList();
  }

  Future<List<StudyLocationModel>> getUnsyncedLocations(String userId) async {
    final db = await _sqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      SqliteHelper.tableStudyLocations,
      where: 'user_id = ? AND is_synced = ?',
      whereArgs: [userId, 0],
    );
    return maps.map((map) => StudyLocationModel.fromMap(map)).toList();
  }

  Future<void> markAsSynced(String id) async {
    final db = await _sqliteHelper.database;
    await db.update(
      SqliteHelper.tableStudyLocations,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteLocation(String id) async {
    final db = await _sqliteHelper.database;
    await db.delete(
      SqliteHelper.tableStudyLocations,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
