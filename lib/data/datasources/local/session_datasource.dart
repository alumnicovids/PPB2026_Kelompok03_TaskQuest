import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class SessionDatasource {
  final SharedPreferences _sharedPreferences;

  SessionDatasource(this._sharedPreferences);

  Future<bool> saveSession({
    required String userId,
    required String username,
  }) async {
    final futures = await Future.wait([
      _sharedPreferences.setBool(AppConstants.keyIsLoggedIn, true),
      _sharedPreferences.setString(AppConstants.keyUserId, userId),
      _sharedPreferences.setString(AppConstants.keyUserName, username),
    ]);
    return futures.every((element) => element == true);
  }

  Future<bool> clearSession() async {
    final futures = await Future.wait([
      _sharedPreferences.remove(AppConstants.keyIsLoggedIn),
      _sharedPreferences.remove(AppConstants.keyUserId),
      _sharedPreferences.remove(AppConstants.keyUserName),
    ]);
    return futures.every((element) => element == true);
  }

  bool isLoggedIn() {
    return _sharedPreferences.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  String? getUserId() {
    return _sharedPreferences.getString(AppConstants.keyUserId);
  }

  String? getUsername() {
    return _sharedPreferences.getString(AppConstants.keyUserName);
  }
}
