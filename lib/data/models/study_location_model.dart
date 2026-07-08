import '../../domain/entities/study_location.dart';

class StudyLocationModel extends StudyLocation {
  const StudyLocationModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.isFavorite,
    required super.isSynced,
  });

  factory StudyLocationModel.fromMap(Map<String, dynamic> map) {
    return StudyLocationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      isFavorite: map['is_favorite'] is bool
          ? map['is_favorite'] as bool
          : (map['is_favorite'] as int) == 1,
      isSynced: map['is_synced'] != null
          ? (map['is_synced'] as int) == 1
          : false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'is_favorite': isFavorite ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'is_favorite': isFavorite,
    };
  }

  factory StudyLocationModel.fromEntity(StudyLocation location) {
    return StudyLocationModel(
      id: location.id,
      userId: location.userId,
      name: location.name,
      latitude: location.latitude,
      longitude: location.longitude,
      isFavorite: location.isFavorite,
      isSynced: location.isSynced,
    );
  }
}
