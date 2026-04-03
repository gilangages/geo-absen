import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../data/api/user_api.dart';
import '../../data/api/auth_api.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserApi _userApi = UserApi(ApiClient());
  final AuthApi _authApi = AuthApi(ApiClient());

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoggingOut = false;
  bool get isLoggingOut => _isLoggingOut;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _name = '';
  String get name => _name;

  String _email = '';
  String get email => _email;

  String _position = '';
  String get position => _position;

  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;

  /// Mengambil data profil dari server.
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _userApi.getCurrentUser();

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      _name = data['name'] ?? '';
      _email = data['email'] ?? '';
      _position = data['position'] ?? '';
      _avatarUrl = data['avatar_url'];
    } else if (response['status_code'] == 401) {
      _errorMessage = 'Sesi habis, silakan login kembali.';
    } else {
      _errorMessage = response['message'] ?? 'Gagal memuat profil.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Logout: hapus token di server dan lokal.
  Future<bool> logout() async {
    _isLoggingOut = true;
    notifyListeners();

    // Kirim DELETE ke server untuk mencabut token
    await _authApi.logout();

    // Hapus token lokal (selalu dilakukan, meskipun server error)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    _isLoggingOut = false;
    notifyListeners();
    return true;
  }
}
