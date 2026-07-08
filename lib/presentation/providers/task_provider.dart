import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepository;
  List<Task> _tasks = [];
  List<Task> _submittedTasks = [];
  bool _isLoading = false;

  TaskProvider(this._taskRepository);

  List<Task> get tasks => _tasks;
  List<Task> get submittedTasks => _submittedTasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasks(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _taskRepository.getTasks(userId);
    } catch (_) {
      // Offline-first: fallback to empty list or keep current tasks
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _taskRepository.getAllTasks();
    } catch (_) {
      // Ignore or fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubmittedTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _submittedTasks = await _taskRepository.getSubmittedTasks();
    } catch (_) {
      // Handle or ignore
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _taskRepository.createTask(task);
      _tasks.insert(0, task);
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _taskRepository.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _taskRepository.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveQuest(
    String taskId,
    String studentUserId,
    int xpReward,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _taskRepository.approveTask(taskId, studentUserId, xpReward);
      _submittedTasks.removeWhere((t) => t.id == taskId);
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectQuest(String taskId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _taskRepository.rejectTask(taskId);
      _submittedTasks.removeWhere((t) => t.id == taskId);
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncTasks(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _taskRepository.syncTasks(userId);
      _tasks = await _taskRepository.getTasks(userId);
    } catch (_) {
      // Ignore background sync errors
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
