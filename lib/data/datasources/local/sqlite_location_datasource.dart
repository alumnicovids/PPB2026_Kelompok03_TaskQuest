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

  Future<void> deleteLocation(String id) async {
    final db = await _sqliteHelper.database;
    await db.delete(
      SqliteHelper.tableStudyLocations,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
