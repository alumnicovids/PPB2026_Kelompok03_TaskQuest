class StudyLocation {
  final String id;
  final String userId;
  final String name;
  final double latitude;
  final double longitude;
  final bool isFavorite;

  const StudyLocation({
    required this.id,
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.isFavorite,
  });

  StudyLocation copyWith({
    String? id,
    String? userId,
    String? name,
    double? latitude,
    double? longitude,
    bool? isFavorite,
  }) {
    return StudyLocation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
