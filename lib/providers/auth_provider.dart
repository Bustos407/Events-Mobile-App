import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserProfile? _user;
  bool _loading = true;

  UserProfile? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  Future<void> loadSession() async {
    _loading = true;
    notifyListeners();
    _user = await _authService.currentUser();
    _loading = false;
    notifyListeners();
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required List<String> interests,
  }) async {
    final error = await _authService.register(
      name: name,
      email: email,
      password: password,
      interests: interests,
    );
    if (error == null) {
      _user = UserProfile(name: name, email: email, interests: interests);
      notifyListeners();
    }
    return error;
  }

  Future<String?> login({required String email, required String password}) async {
    final error = await _authService.login(email: email, password: password);
    if (error == null) {
      _user = await _authService.currentUser();
      notifyListeners();
    }
    return error;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> updateInterests(List<String> interests) async {
    if (_user == null) return;
    await _authService.updateInterests(_user!.email, interests);
    _user = _user!.copyWith(interests: interests);
    notifyListeners();
  }
}
