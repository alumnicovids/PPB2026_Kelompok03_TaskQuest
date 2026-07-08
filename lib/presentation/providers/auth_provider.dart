import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userId;
  String? _username;
  String? _role;
  List<UserEntity> _users = [];

  AuthProvider(this._authRepository) {
    checkSession();
  }

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get username => _username;
  String? get role => _role;
  List<UserEntity> get users => _users;

  void checkSession() {
    _isLoggedIn = _authRepository.isLoggedIn();
    if (_isLoggedIn) {
      _userId = _authRepository.getUserId();
      _username = _authRepository.getUsername();
      _role = _authRepository.getRole();
    } else {
      _userId = null;
      _username = null;
      _role = null;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _authRepository.login(username, password);
      if (success) {
        checkSession();
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _authRepository.register(username, email, password);
      if (success) {
        checkSession();
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.logout();
      checkSession();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsersByRole(String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await _authRepository.getUsersByRole(role);
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await _authRepository.getAllUsers();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeUserRole(String userId, String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.updateUserRole(userId, role);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(role: role);
      }
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeUsername(String newUsername) async {
    final uid = _userId;
    if (uid == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.updateUsername(uid, newUsername);
      _username = newUsername;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerLecturer(
    String username,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _authRepository.registerDosen(username, email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
