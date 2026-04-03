import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SplashState { initial, loading, authenticated, unauthenticated }

class SplashViewModel extends ChangeNotifier {
  SplashState _state = SplashState.initial;
  SplashState get state => _state;

  Future<void> checkToken() async {
    _state = SplashState.loading;
    notifyListeners();

    // Memberi jeda buatan agar Splash Screen muncul sejenak (opsional)
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      _state = SplashState.authenticated;
    } else {
      _state = SplashState.unauthenticated;
    }
    
    notifyListeners();
  }
}
