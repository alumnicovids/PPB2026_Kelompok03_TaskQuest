import '../entities/task.dart';

abstract class TaskRepository {
  Future<void> createTask(Task task);
  Future<List<Task>> getTasks(String userId);
  Future<Task?> getTaskById(String taskId);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<void> syncTasks(String userId);
  Future<List<Task>> getSubmittedTasks();
  Future<void> approveTask(String taskId, String studentUserId, int xpReward);
  Future<void> rejectTask(String taskId);
}
