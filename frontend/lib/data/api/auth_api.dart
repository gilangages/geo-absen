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
}
