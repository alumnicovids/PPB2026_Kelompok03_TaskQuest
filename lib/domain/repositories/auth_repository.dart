import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<bool> login(String username, String password);
  Future<bool> register(String username, String email, String password);
  Future<bool> registerDosen(String username, String email, String password);
  Future<void> logout();
  bool isLoggedIn();
  String? getUserId();
  String? getUsername();
  String? getRole();
  Future<List<UserEntity>> getAllUsers();
  Future<List<UserEntity>> getUsersByRole(String role);
  Future<void> updateUserRole(String userId, String role);
}
