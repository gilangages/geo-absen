import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../data/api/auth_api.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthApi _authApi = AuthApi(ApiClient());
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authApi.login(email, password);

      if (response['success'] == true) {
        // Simpan token
        final token = response['data']['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Ambil error validasi jika ada, atau message default
        final errors = response['errors'];
        if (errors != null && errors.isNotEmpty) {
          final firstErrorKey = errors.keys.first;
          _errorMessage = errors[firstErrorKey][0];
        } else {
          _errorMessage = response['message'] ?? 'Login gagal.';
        }
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
