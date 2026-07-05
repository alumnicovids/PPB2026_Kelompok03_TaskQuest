class Character {
  final String id;
  final String userId;
  final String classType; // 'knight', 'mage', 'archer'
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final int appearanceStage;
  final DateTime updatedAt;

  const Character({
    required this.id,
    required this.userId,
    required this.classType,
    required this.level,
    required this.currentXp,
    required this.xpToNextLevel,
    required this.appearanceStage,
    required this.updatedAt,
  });

  Character copyWith({
    String? id,
    String? userId,
    String? classType,
    int? level,
    int? currentXp,
    int? xpToNextLevel,
    int? appearanceStage,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      classType: classType ?? this.classType,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      appearanceStage: appearanceStage ?? this.appearanceStage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
