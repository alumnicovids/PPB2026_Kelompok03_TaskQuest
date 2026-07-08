import '../../domain/entities/xp_log.dart';
import '../../domain/repositories/xp_log_repository.dart';
import '../datasources/local/sqlite_xp_log_datasource.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
import '../models/xp_log_model.dart';

class XpLogRepositoryImpl implements XpLogRepository {
  final SqliteXpLogDatasource _sqliteXpLogDatasource;
  final SupabaseRemoteDatasource _supabaseRemoteDatasource;

  XpLogRepositoryImpl(
    this._sqliteXpLogDatasource,
    this._supabaseRemoteDatasource,
  );

  @override
  Future<void> saveXpLog(XpLog xpLog) async {
    final model = XpLogModel.fromEntity(xpLog);
    // 1. Save locally to SQLite cache
    await _sqliteXpLogDatasource.insertXpLog(model);

    // 2. Try to sync to Supabase remote DB
    try {
      await _supabaseRemoteDatasource.insertXpLog(model.toMap());
      await _sqliteXpLogDatasource.markAsSynced(xpLog.id);
    } catch (_) {
      // Offline-first: ignore connection errors, log is saved locally
    }
  }

  @override
  Future<List<XpLog>> getXpLogs(String userId) async {
    // Return offline-first local cached XP logs
    return await _sqliteXpLogDatasource.getXpLogs(userId);
  }

  @override
  Future<void> syncXpLogs(String userId) async {
    // 1. Push unsynced local logs to Supabase remote database
    final unsyncedLogs = await _sqliteXpLogDatasource.getUnsyncedXpLogs(userId);
    for (final log in unsyncedLogs) {
      await _supabaseRemoteDatasource.insertXpLog(log.toMap());
      await _sqliteXpLogDatasource.markAsSynced(log.id);
    }

    // 2. Pull remote logs from Supabase and cache/save to local SQLite
    final remoteLogsData = await _supabaseRemoteDatasource.getXpLogs(userId);
    for (final data in remoteLogsData) {
      final remoteLog = XpLogModel.fromMap(data);
      // Save/cache locally
      await _sqliteXpLogDatasource.insertXpLog(XpLogModel.fromEntity(remoteLog));
      await _sqliteXpLogDatasource.markAsSynced(remoteLog.id);
    }
  }
}
