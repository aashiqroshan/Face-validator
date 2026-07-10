import 'dart:async';
import 'dart:developer';

import 'package:face_validator/presentation/homescreen/homescreen.dart';
import 'package:face_validator/presentation/login/login_page.dart';
import 'package:face_validator/services/storage/hive_service.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final HiveService _hiveService = HiveService();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
  final email = await _hiveService.getLoggedInUser();
  log('zzrr is null ? $email');
  

  if (email == null) {
    _goToLogin();
    return;
  }

  final user = await _hiveService.getUserByEmail(email);

  if (!mounted) return;

  if (user != null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Homescreen(),
      ),
    );
  } else {
    await _hiveService.logout();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }
}

void _goToLogin() {
  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginPage(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_red_eye_outlined,
              size: 70,
              color: Color(0xFFF2C200),
            ),
            SizedBox(height: 20),
            Text(
              "Face Validator",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              color: Color(0xFFF2C200),
            ),
          ],
        ),
      ),
    );
  }
}