import '../../core/network/api_client.dart';

class UserApi {
  final ApiClient _apiClient;

  UserApi(this._apiClient);

  /// Mengambil data profil karyawan yang sedang login.
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _apiClient.get('/users/current');
  }
}
