import '../../domain/entities/study_location.dart';

class StudyLocationModel extends StudyLocation {
  const StudyLocationModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.isFavorite,
  });

  factory StudyLocationModel.fromMap(Map<String, dynamic> map) {
    return StudyLocationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      isFavorite: (map['is_favorite'] as int) == 1,
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
    );
  }
}
