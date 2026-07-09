import 'package:face_validator/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class LoginBloc extends ChangeNotifier {
  final AuthService _authService = AuthService();
  LoginBloc();

  bool isLoading = false;

  Future<bool> login({required String email,required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await _authService.loginUser(
        email: email,
        password: password,
      );

      isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}