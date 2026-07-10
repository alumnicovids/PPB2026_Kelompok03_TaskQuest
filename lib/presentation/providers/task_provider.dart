import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/approve_task_use_case.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepository;
  final ApproveTaskUseCase _approveTaskUseCase;
  List<Task> _tasks = [];
  List<Task> _submittedTasks = [];
  bool _isLoading = false;

  TaskProvider(this._taskRepository, this._approveTaskUseCase);

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

  Future<void> addTasks(List<Task> newTasks) async {
    _isLoading = true;
    notifyListeners();
    try {
      for (final task in newTasks) {
        await _taskRepository.createTask(task);
      }
      _tasks.insertAll(0, newTasks);
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

  Future<void> deleteTask(String taskId, {String? role}) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      if (role == 'mahasiswa' &&
          task.assignments != null &&
          task.assignments!.isNotEmpty) {
        throw Exception('Mahasiswa cannot delete tasks assigned by a lecturer.');
      }
    }
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

  Future<void> approveQuest(String taskId, String studentUserId) async {
    _isLoading = true;
    Future.microtask(notifyListeners);
    try {
      await _approveTaskUseCase.execute(
        ApproveTaskParams(taskId: taskId, studentUserId: studentUserId),
      );
      _submittedTasks.removeWhere(
        (t) =>
            t.id == taskId &&
            t.userId.toLowerCase() == studentUserId.toLowerCase(),
      );
    } catch (e) {
      debugPrint('approveQuest error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      Future.microtask(notifyListeners);
    }
  }

  Future<void> rejectQuest(String taskId, String studentUserId) async {
    _isLoading = true;
    Future.microtask(notifyListeners);
    try {
      await _taskRepository.rejectTask(taskId, studentUserId);
      _submittedTasks.removeWhere(
        (t) =>
            t.id == taskId &&
            t.userId.toLowerCase() == studentUserId.toLowerCase(),
      );
    } catch (e) {
      debugPrint('rejectQuest error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      Future.microtask(notifyListeners);
    }
  }

  Future<void> syncTasks(String userId, {String? role}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _taskRepository.syncTasks(userId);
      if (role == 'mahasiswa') {
        _tasks = await _taskRepository.getTasks(userId);
      } else {
        _tasks = await _taskRepository.getAllTasks();
      }
      debugPrint('Provider sync successful. Total tasks loaded: ${_tasks.length}');
    } catch (e, stack) {
      debugPrint('TaskProvider syncTasks error: $e');
      debugPrint(stack.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
