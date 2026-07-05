import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userId;
  String? _username;

  AuthProvider(this._authRepository) {
    checkSession();
  }

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get username => _username;

  void checkSession() {
    _isLoggedIn = _authRepository.isLoggedIn();
    if (_isLoggedIn) {
      _userId = _authRepository.getUserId();
      _username = _authRepository.getUsername();
    } else {
      _userId = null;
      _username = null;
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
}
