class XpLog {
  final String id;
  final String userId;
  final String? taskId;
  final int xpAmount;
  final String reason;
  final DateTime createdAt;

  const XpLog({
    required this.id,
    required this.userId,
    this.taskId,
    required this.xpAmount,
    required this.reason,
    required this.createdAt,
  });

  XpLog copyWith({
    String? id,
    String? userId,
    String? taskId,
    int? xpAmount,
    String? reason,
    DateTime? createdAt,
  }) {
    return XpLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      xpAmount: xpAmount ?? this.xpAmount,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
