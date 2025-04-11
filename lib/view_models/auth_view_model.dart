import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  User? _user;
  bool isLoading = false;
  String? error;

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final user = User(
        username: username,
        email: email,
        password: password,
      );

      final response = await _authService.register(user);

      if (response.success && response.data != null) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = response.message ?? 'Sign up failed';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Register error: $e');
      }
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      if (response.success && response.data != null) {
        final prefs = await SharedPreferences.getInstance();

        if (response.data['token']?['accessToken'] != null) {
          await prefs.setString(
              'accessToken', response.data['token']['accessToken']);
        }

        if (response.data['token']?['refreshToken'] != null) {
          await prefs.setString(
              'refreshToken', response.data['token']['refreshToken']);
        }

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = response.message ?? 'Login failed';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadIsLoggedInFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    _isLoggedIn = accessToken != null && refreshToken != null;
    notifyListeners();
  }

  Future<void> fetchUserInfo() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final response = await _authService.getCurrentUser(accessToken!);

    if (response.success && response.data != null) {
      _user = User.fromJson(response.data);
      isLoading = false;
      _isLoggedIn = true;
      notifyListeners();
    } else {
      isLoading = false;
      error = response.message;
      logout();
      throw response;
    }
  }

  Future<void> logout() async {
    final response = await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }
}
