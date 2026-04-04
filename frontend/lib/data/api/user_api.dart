import '../../core/network/api_client.dart';

class UserApi {
  final ApiClient _apiClient;

  UserApi(this._apiClient);

  /// Mengambil data profil karyawan yang sedang login.
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _apiClient.get('/users/current');
  }

  /// Update profil karyawan (Nama, Email, Password, Avatar).
  /// Menggunakan POST dengan field _method: PATCH (Spoofing).
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? password,
    String? passwordConfirmation,
    List<int>? avatarBytes,
    String? avatarName,
  }) async {
    final Map<String, String> fields = {
      '_method': 'PATCH',
      'name': name,
      'email': email,
    };

    if (password != null && password.isNotEmpty) {
      fields['password'] = password;
      fields['password_confirmation'] = passwordConfirmation ?? '';
    }

    return await _apiClient.multipartPost(
      '/users/current',
      fields: fields,
      fileBytes: avatarBytes,
      fileName: avatarName,
      fileFieldName: 'avatar',
    );
  }
}
