import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import '../models/user.dart';

class AuthService {
  static const String _keyUserId = 'user_id';
  static const String _keyEmail = 'user_email';

  final DBHelper _dbHelper = DBHelper();

  /// Attempt login. Returns the User on success, null on failure.
  Future<User?> login(String email, String password) async {
    final user = await _dbHelper.getUser(email, password);
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyUserId, user.id!);
      await prefs.setString(_keyEmail, email);
    }
    return user;
  }

  /// Register a new user. Returns the inserted row id.
  Future<int> register(String email, String password) async {
    final user = User(email: email, password: password);
    return await _dbHelper.insertUser(user);
  }

  /// Check if email is already taken.
  Future<bool> emailExists(String email) async {
    return await _dbHelper.emailExists(email);
  }

  /// Check if a user session exists.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }

  /// Get the current logged-in user's id.
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Logout — clear session.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyEmail);
  }
}
