import '../../domain/entities/character.dart';

class CharacterModel extends Character {
  const CharacterModel({
    required super.id,
    required super.userId,
    required super.classType,
    required super.level,
    required super.currentXp,
    required super.xpToNextLevel,
    required super.appearanceStage,
    required super.updatedAt,
  });

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      classType: map['class_type'] as String,
      level: map['level'] as int,
      currentXp: map['current_xp'] as int,
      xpToNextLevel: map['xp_to_next_level'] as int,
      appearanceStage: map['appearance_stage'] as int,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'class_type': classType,
      'level': level,
      'current_xp': currentXp,
      'xp_to_next_level': xpToNextLevel,
      'appearance_stage': appearanceStage,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CharacterModel.fromEntity(Character char) {
    return CharacterModel(
      id: char.id,
      userId: char.userId,
      classType: char.classType,
      level: char.level,
      currentXp: char.currentXp,
      xpToNextLevel: char.xpToNextLevel,
      appearanceStage: char.appearanceStage,
      updatedAt: char.updatedAt,
    );
  }
}
