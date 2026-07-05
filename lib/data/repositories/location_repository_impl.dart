import '../../domain/entities/study_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/local/sqlite_location_datasource.dart';
import '../models/study_location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  final SqliteLocationDatasource _sqliteLocationDatasource;

  LocationRepositoryImpl(this._sqliteLocationDatasource);

  @override
  Future<void> saveLocation(StudyLocation location) async {
    final model = StudyLocationModel.fromEntity(location);
    await _sqliteLocationDatasource.insertLocation(model);
  }

  @override
  Future<List<StudyLocation>> getLocations(String userId) async {
    return await _sqliteLocationDatasource.getLocations(userId);
  }

  @override
  Future<void> deleteLocation(String id) async {
    await _sqliteLocationDatasource.deleteLocation(id);
  }
}
