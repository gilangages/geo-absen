import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../data/api/auth_api.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthApi _authApi = AuthApi(ApiClient());

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String position,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authApi.register(name, email, password, passwordConfirmation, position);

      if (response['success'] == true) {
        _successMessage = response['message'] ?? 'Pendaftaran berhasil, silakan login.';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errors = response['errors'];
        if (errors != null && errors.isNotEmpty) {
          final firstErrorKey = errors.keys.first;
          _errorMessage = errors[firstErrorKey][0];
        } else {
          _errorMessage = response['message'] ?? 'Pendaftaran gagal.';
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
