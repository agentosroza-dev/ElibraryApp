import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _log = Logger();

  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;
  bool _success = false;
  Map<String, dynamic>? _user;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  bool get success => _success;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get hasPassword => _user?['has_password'] == true;
  String get userName => _user?['name'] ?? '';
  String get userEmail => _user?['email'] ?? '';
  String? get userPhoto => _user?['photo'] as String? ?? _user?['profile_photo'] as String? ?? _user?['avatar'] as String?;

  Future<void> tryAutoLogin() async {
    _isInitializing = true;
    notifyListeners();

    try {
      final storedToken = await _storage.read(key: 'auth_token');
      if (storedToken == null) {
        _log.d('No stored token found');
        _isInitializing = false;
        notifyListeners();
        return;
      }

      _log.d('Found stored token, verifying...');
      _token = storedToken;

      try {
        final data = await _authService.verifyAccount();
        _user = data['user'] as Map<String, dynamic>?;
        _log.d('Token verified, user: ${_user?['name'] ?? 'unknown'}');
      } catch (e) {
        _log.w('Token invalid, clearing: $e');
        await _clearAuth();
      }
    } catch (e) {
      _log.e('Auto-login error: $e');
    }

    _isInitializing = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _log.d('Attempting login for: $email');
      final data = await _authService.signin(email, password);
      _log.d('Login response keys: ${data.keys}');

      _user = data['user'] as Map<String, dynamic>?;
      _token = data['token'] as String?;

      _token ??= data['access_token'] as String?;

      if (_token != null) {
        await _storage.write(key: 'auth_token', value: _token!);
        _log.d('Token stored successfully');
      } else {
        _log.e('No token in response');
        _error = 'Server did not return an authentication token';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _log.e('Login failed: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccess() {
    _success = false;
    notifyListeners();
  }

  Future<bool> updateName(String name) async {
    _isLoading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final data = await _authService.updateProfileName(name);
      _user = data['user'] as Map<String, dynamic>?;
      _user ??= data['data'] as Map<String, dynamic>?;
      _success = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _isLoading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      _success = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePhoto(String base64Photo) async {
    _isLoading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final data = await _authService.updatePhoto(base64Photo);
      _user = data['user'] as Map<String, dynamic>?;
      _user ??= data['data'] as Map<String, dynamic>?;
      _success = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPassword({
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _isLoading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      await _authService.createPassword(
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      _success = true;
      if (_user != null) {
        _user!['has_password'] = true;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _log.d('Logging out');
    try {
      await _authService.signout();
    } catch (e) {
      _log.w('Signout API call failed: $e');
    }
    await _clearAuth();
  }

  Future<void> _clearAuth() async {
    _user = null;
    _token = null;
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }
}
