import 'package:uuid/uuid.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/session_datasource.dart';
import '../datasources/local/sqlite_helper.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseRemoteDatasource _supabaseRemoteDatasource;
  final SessionDatasource _sessionDatasource;

  AuthRepositoryImpl(this._supabaseRemoteDatasource, this._sessionDatasource);

  @override
  Future<bool> login(String username, String password) async {
    try {
      final userData = await _supabaseRemoteDatasource.getUserByUsername(
        username,
      );
      if (userData != null) {
        final storedPassword = userData['password_hash'] as String;
        if (storedPassword == password) {
          final userId = userData['id'] as String;
          final role = userData['role'] as String? ?? 'mahasiswa';
          await _sessionDatasource.saveSession(
            userId: userId,
            username: username,
            role: role,
          );
          return true;
        }
      }
    } catch (_) {
      // Return false if offline or query fails
    }
    return false;
  }

  @override
  Future<bool> register(String username, String email, String password) async {
    try {
      final existingUser = await _supabaseRemoteDatasource.getUserByUsername(
        username,
      );
      if (existingUser != null) {
        return false; // Username already taken
      }

      final userId = const Uuid().v4();
      final userData = {
        'id': userId,
        'username': username,
        'email': email,
        'password_hash':
            password, // Storing password directly for simplicity in student project
        'role': 'mahasiswa',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseRemoteDatasource.insertUser(userData);

      // Save session
      await _sessionDatasource.saveSession(
        userId: userId,
        username: username,
        role: 'mahasiswa',
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> registerDosen(
    String username,
    String email,
    String password,
  ) async {
    try {
      final existingUser = await _supabaseRemoteDatasource.getUserByUsername(
        username,
      );
      if (existingUser != null) {
        return false; // Username already taken
      }

      final userId = const Uuid().v4();
      final userData = {
        'id': userId,
        'username': username,
        'email': email,
        'password_hash': password,
        'role': 'dosen',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseRemoteDatasource.insertUser(userData);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await _sessionDatasource.clearSession();
    try {
      await SqliteHelper().clearAllData();
    } catch (_) {}
  }

  @override
  bool isLoggedIn() {
    return _sessionDatasource.isLoggedIn();
  }

  @override
  String? getUserId() {
    return _sessionDatasource.getUserId();
  }

  @override
  String? getUsername() {
    return _sessionDatasource.getUsername();
  }

  @override
  String? getRole() {
    return _sessionDatasource.getRole();
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final rawUsers = await _supabaseRemoteDatasource.getAllUsers();
    return rawUsers.map<UserEntity>((map) => UserModel.fromMap(map)).toList();
  }

  @override
  Future<List<UserEntity>> getUsersByRole(String role) async {
    final rawUsers = await _supabaseRemoteDatasource.getUsersByRole(role);
    return rawUsers.map<UserEntity>((map) => UserModel.fromMap(map)).toList();
  }

  @override
  Future<void> updateUserRole(String userId, String role) async {
    await _supabaseRemoteDatasource.updateUser(userId, {'role': role});
  }

  @override
  Future<void> updateUsername(String userId, String newUsername) async {
    await _supabaseRemoteDatasource.updateUser(userId, {
      'username': newUsername,
    });
    final role = _sessionDatasource.getRole() ?? 'mahasiswa';
    await _sessionDatasource.saveSession(
      userId: userId,
      username: newUsername,
      role: role,
    );
  }
}
