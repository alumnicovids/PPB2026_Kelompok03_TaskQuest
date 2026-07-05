import '../entities/study_location.dart';

abstract class LocationRepository {
  Future<void> saveLocation(StudyLocation location);
  Future<List<StudyLocation>> getLocations(String userId);
  Future<void> deleteLocation(String id);
}
