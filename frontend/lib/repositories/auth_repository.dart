// lib/repositories/auth_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthRepository {
  static const _userKey = 'auth_user';

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    final map = jsonDecode(json) as Map<String, dynamic>;
    return User.fromMap(map);
  }

  Future<void> persistUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
