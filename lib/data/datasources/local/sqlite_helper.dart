import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteHelper {
  static const String _databaseName = 'taskquest.db';
  static const int _databaseVersion = 1;

  // Table Names
  static const String tableTasks = 'tasks';
  static const String tableStudyLocations = 'study_locations';
  static const String tableXpLogs = 'xp_logs';

  // Singleton instance
  static final SqliteHelper _instance = SqliteHelper._internal();
  factory SqliteHelper() => _instance;
  SqliteHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tasks table
    await db.execute('''
      CREATE TABLE $tableTasks (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        priority TEXT NOT NULL,
        deadline TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        xp_reward INTEGER NOT NULL,
        proof_photo_path TEXT,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create study_locations table
    await db.execute('''
      CREATE TABLE $tableStudyLocations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create xp_logs cache table
    await db.execute('''
      CREATE TABLE $tableXpLogs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        task_id TEXT,
        xp_amount INTEGER NOT NULL,
        reason TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
