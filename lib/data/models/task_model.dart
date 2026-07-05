import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.category,
    required super.priority,
    required super.deadline,
    required super.status,
    required super.xpReward,
    super.proofPhotoPath,
    super.completedAt,
    required super.createdAt,
    required super.isSynced,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      priority: map['priority'] as String,
      deadline: DateTime.parse(map['deadline'] as String),
      status: map['status'] as String,
      xpReward: map['xp_reward'] as int,
      proofPhotoPath: map['proof_photo_path'] as String?,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      isSynced: (map['is_synced'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'xp_reward': xpReward,
      'proof_photo_path': proofPhotoPath,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      category: task.category,
      priority: task.priority,
      deadline: task.deadline,
      status: task.status,
      xpReward: task.xpReward,
      proofPhotoPath: task.proofPhotoPath,
      completedAt: task.completedAt,
      createdAt: task.createdAt,
      isSynced: task.isSynced,
    );
  }
}
