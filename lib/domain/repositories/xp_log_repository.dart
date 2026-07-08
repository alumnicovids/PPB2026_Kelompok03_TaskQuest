import '../entities/xp_log.dart';

abstract class XpLogRepository {
  Future<void> saveXpLog(XpLog xpLog);
  Future<List<XpLog>> getXpLogs(String userId);
  Future<void> syncXpLogs(String userId);
}
