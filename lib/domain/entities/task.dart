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
    );
  }
}
