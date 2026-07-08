import '../../domain/entities/study_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/local/sqlite_location_datasource.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
import '../models/study_location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  final SqliteLocationDatasource _sqliteLocationDatasource;
  final SupabaseRemoteDatasource _supabaseRemoteDatasource;

  LocationRepositoryImpl(
    this._sqliteLocationDatasource,
    this._supabaseRemoteDatasource,
  );

  @override
  Future<void> saveLocation(StudyLocation location) async {
    final model = StudyLocationModel.fromEntity(location.copyWith(isSynced: false));
    await _sqliteLocationDatasource.insertLocation(model);

    try {
      await _supabaseRemoteDatasource.upsertLocation(model.toSupabaseMap());
      await _sqliteLocationDatasource.markAsSynced(location.id);
    } catch (_) {
      // Offline-first
    }
  }

  @override
  Future<List<StudyLocation>> getLocations(String userId) async {
    return await _sqliteLocationDatasource.getLocations(userId);
  }

  @override
  Future<void> deleteLocation(String id) async {
    await _sqliteLocationDatasource.deleteLocation(id);

    try {
      await _supabaseRemoteDatasource.deleteRemoteLocation(id);
    } catch (_) {
      // Offline-first
    }
  }

  @override
  Future<void> syncLocations(String userId) async {
    // 1. Push all unsynced local study spots to Supabase
    final unsyncedSpots = await _sqliteLocationDatasource.getUnsyncedLocations(userId);
    for (final spot in unsyncedSpots) {
      await _supabaseRemoteDatasource.upsertLocation(spot.toSupabaseMap());
      await _sqliteLocationDatasource.markAsSynced(spot.id);
    }

    // 2. Pull remote study spots from Supabase and cache/save to local SQLite
    final remoteSpotsData = await _supabaseRemoteDatasource.getLocations(userId);
    for (final data in remoteSpotsData) {
      final remoteSpot = StudyLocationModel.fromMap(data).copyWith(isSynced: true);
      await _sqliteLocationDatasource.insertLocation(StudyLocationModel.fromEntity(remoteSpot));
    }
  }
}
