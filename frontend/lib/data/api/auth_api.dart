import '../../core/network/api_client.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final body = {
      'email': email,
      'password': password,
    };
    return await _apiClient.post('/auth/login', body: body);
  }

  Future<Map<String, dynamic>> logout() async {
    return await _apiClient.delete('/auth/logout');
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation, String position) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'position': position,
    };
    return await _apiClient.post('/auth/register', body: body);
  }
}
