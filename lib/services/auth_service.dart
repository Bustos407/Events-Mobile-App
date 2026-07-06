import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Local mock auth using SharedPreferences. Replace with Firebase Auth later.
class AuthService {
  static const _usersKey = 'registered_users';
  static const _sessionKey = 'session_email';

  Future<Map<String, dynamic>> _readUsers(SharedPreferences prefs) async {
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> _writeUsers(SharedPreferences prefs, Map<String, dynamic> users) async {
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required List<String> interests,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _readUsers(prefs);
    if (users.containsKey(email)) {
      return 'Ya existe una cuenta con ese correo.';
    }
    users[email] = {
      'password': password,
      'profile': UserProfile(name: name, email: email, interests: interests).toJson(),
    };
    await _writeUsers(prefs, users);
    await prefs.setString(_sessionKey, email);
    return null;
  }

  Future<String?> login({required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _readUsers(prefs);
    final entry = users[email] as Map<String, dynamic>?;
    if (entry == null || entry['password'] != password) {
      return 'Correo o contraseña incorrectos.';
    }
    await prefs.setString(_sessionKey, email);
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<UserProfile?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return null;
    final users = await _readUsers(prefs);
    final entry = users[email] as Map<String, dynamic>?;
    if (entry == null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(entry['profile'] as Map));
  }

  Future<void> updateInterests(String email, List<String> interests) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _readUsers(prefs);
    final entry = users[email] as Map<String, dynamic>?;
    if (entry == null) return;
    final profile = UserProfile.fromJson(Map<String, dynamic>.from(entry['profile'] as Map));
    entry['profile'] = profile.copyWith(interests: interests).toJson();
    users[email] = entry;
    await _writeUsers(prefs, users);
  }
}
