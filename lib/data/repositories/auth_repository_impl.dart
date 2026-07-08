import 'package:uuid/uuid.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/session_datasource.dart';
import '../datasources/remote/supabase_remote_datasource.dart';

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

      // Create initial Character for this user
      final characterId = const Uuid().v4();
      final characterData = {
        'id': characterId,
        'user_id': userId,
        'class_type': 'knight',
        'level': 1,
        'current_xp': 0,
        'xp_to_next_level': 100,
        'appearance_stage': 1,
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _supabaseRemoteDatasource.upsertCharacter(characterData);

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
}
