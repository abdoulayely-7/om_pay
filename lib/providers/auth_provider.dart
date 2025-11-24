import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../config/config.dart';
import '../services/auth/auth_service.dart';
import '../dto/request/login_request.dart';
import '../dto/request/register_request.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService(Config.apiBaseUrl);
  late final AuthService _authService;

  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  AuthProvider() {
    _authService = AuthService(_api);
    _loadToken();
  }

  // Getters
  String? get token => _token;
  bool get isLoggedIn => _token != null && _isInitialized;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  // Load token from SharedPreferences
  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _isInitialized = true;
      print('Token loaded from SharedPreferences: $_token');
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement du token';
      _isInitialized = true;
      print('Error loading token: $e');
      notifyListeners();
    }
  }

  // Save token to SharedPreferences
  Future<void> _saveToken(String? token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString('token', token);
      } else {
        await prefs.remove('token');
      }
      _token = token;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la sauvegarde du token';
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String identifier, String password, {String? code}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = LoginRequest(
        identifier: identifier,
        password: password,
        code: code,
      );

      final response = await _authService.login(request);
      await _saveToken(response.accessToken);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String telephone,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        telephone: telephone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      await _authService.register(request);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _saveToken(null);
    _error = null;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}