import '../../domain/entities/xp_log.dart';

class XpLogModel extends XpLog {
  const XpLogModel({
    required super.id,
    required super.userId,
    super.taskId,
    required super.xpAmount,
    required super.reason,
    required super.createdAt,
  });

  factory XpLogModel.fromMap(Map<String, dynamic> map) {
    return XpLogModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      taskId: map['task_id'] as String?,
      xpAmount: map['xp_amount'] as int,
      reason: map['reason'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'task_id': taskId,
      'xp_amount': xpAmount,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory XpLogModel.fromEntity(XpLog log) {
    return XpLogModel(
      id: log.id,
      userId: log.userId,
      taskId: log.taskId,
      xpAmount: log.xpAmount,
      reason: log.reason,
      createdAt: log.createdAt,
    );
  }
}
