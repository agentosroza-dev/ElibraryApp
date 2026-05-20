import '../config/api_config.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> signin(String email, String password) async {
    return _client.post(
      ApiConfig.signin,
      body: {'email': email, 'password': password},
    );
  }

  Future<Map<String, dynamic>> verifyAccount() async {
    return _client.get(ApiConfig.verifyAccount, authenticate: true);
  }

  Future<Map<String, dynamic>> signout() async {
    return _client.post(ApiConfig.signout, authenticate: true);
  }

  Future<Map<String, dynamic>> updateProfileName(String name) async {
    return _client.patch(
      ApiConfig.userProfile,
      body: {'name': name},
      authenticate: true,
    );
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
    bool terminateSessions = false,
  }) async {
    return _client.patch(
      ApiConfig.passwordChange,
      body: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
        'terminate_sessions': terminateSessions,
      },
      authenticate: true,
    );
  }

  Future<Map<String, dynamic>> updatePhoto(String base64Photo) async {
    return _client.patch(
      ApiConfig.updatePhoto,
      body: {'photo': base64Photo},
      authenticate: true,
    );
  }

  Future<Map<String, dynamic>> createPassword({
    required String newPassword,
    required String newPasswordConfirmation,
    bool terminateSessions = false,
  }) async {
    return _client.patch(
      ApiConfig.passwordCreate,
      body: {
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
        'terminate_sessions': terminateSessions,
      },
      authenticate: true,
    );
  }
}
