import 'dart:io';

import 'package:face_validator/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterBloc extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;

  Future<bool> registerUser({
  required String email,
  required String password,
  required List<File> images,
}) async {
  try {
    isLoading = true;
    notifyListeners();

    await _authService.registerUser(
      email: email,
      password: password,
      images: images,
    );

    isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    isLoading = false;
    print('Error: $e');
    notifyListeners();
    return false;
  }
}
}