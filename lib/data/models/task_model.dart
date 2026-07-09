import 'dart:convert';
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
    super.studentUsername,
    super.assignments,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    final usersMap = map['users'] as Map<String, dynamic>?;
    final studentUsername = usersMap != null
        ? usersMap['username'] as String?
        : map['student_username'] as String?;

    List<TaskAssignment>? assignmentsList;
    if (map['assignments'] != null) {
      final dynamic rawAssignments = map['assignments'];
      if (rawAssignments is String) {
        try {
          final List<dynamic> decoded =
              jsonDecode(rawAssignments) as List<dynamic>;
          assignmentsList = decoded
              .map(
                (e) =>
                    TaskAssignment.fromMap(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
        } catch (_) {}
      } else if (rawAssignments is List) {
        assignmentsList = rawAssignments
            .map(
              (e) =>
                  TaskAssignment.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
    }

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
      isSynced: map['is_synced'] != null
          ? (map['is_synced'] as int) == 1
          : false,
      studentUsername: studentUsername,
      assignments: assignmentsList,
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
      if (assignments != null)
        'assignments': jsonEncode(assignments!.map((e) => e.toMap()).toList()),
    };
  }

  Map<String, dynamic> toSupabaseMap() {
    final map = toMap();
    map.remove('is_synced');
    if (assignments != null) {
      map['assignments'] = assignments!.map((e) => e.toMap()).toList();
    }
    return map;
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
      studentUsername: task.studentUsername,
      assignments: task.assignments,
    );
  }
}
