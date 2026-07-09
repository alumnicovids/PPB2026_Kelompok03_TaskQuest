class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String category; // 'kuliah', 'organisasi', 'pribadi'
  final String priority; // 'low', 'medium', 'high'
  final DateTime deadline;
  final String status; // 'pending', 'in_progress', 'completed'
  final int xpReward;
  final String? proofPhotoPath;
  final DateTime? completedAt;
  final DateTime createdAt;
  final bool isSynced;
  final String? studentUsername;
  final List<TaskAssignment>? assignments;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.deadline,
    required this.status,
    required this.xpReward,
    this.proofPhotoPath,
    this.completedAt,
    required this.createdAt,
    required this.isSynced,
    this.studentUsername,
    this.assignments,
  });

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? priority,
    DateTime? deadline,
    String? status,
    int? xpReward,
    String? proofPhotoPath,
    DateTime? completedAt,
    DateTime? createdAt,
    bool? isSynced,
    String? studentUsername,
    List<TaskAssignment>? assignments,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      xpReward: xpReward ?? this.xpReward,
      proofPhotoPath: proofPhotoPath ?? this.proofPhotoPath,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      studentUsername: studentUsername ?? this.studentUsername,
      assignments: assignments ?? this.assignments,
    );
  }
}

class TaskAssignment {
  final String studentId;
  final String studentUsername;
  final String status; // 'pending', 'submitted', 'completed'
  final String? proofPhotoPath;
  final DateTime? completedAt;

  const TaskAssignment({
    required this.studentId,
    required this.studentUsername,
    required this.status,
    this.proofPhotoPath,
    this.completedAt,
  });

  TaskAssignment copyWith({
    String? studentId,
    String? studentUsername,
    String? status,
    String? proofPhotoPath,
    DateTime? completedAt,
  }) {
    return TaskAssignment(
      studentId: studentId ?? this.studentId,
      studentUsername: studentUsername ?? this.studentUsername,
      status: status ?? this.status,
      proofPhotoPath: proofPhotoPath ?? this.proofPhotoPath,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'student_username': studentUsername,
      'status': status,
      'proof_photo_path': proofPhotoPath,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory TaskAssignment.fromMap(Map<String, dynamic> map) {
    return TaskAssignment(
      studentId: map['student_id'] as String,
      studentUsername: map['student_username'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      proofPhotoPath: map['proof_photo_path'] as String?,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }
}
