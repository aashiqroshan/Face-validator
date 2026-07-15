import 'dart:developer';
import 'dart:io';
import 'package:face_validator/models/face_registeration_model.dart';
import 'package:face_validator/presentation/login/login_page.dart';
import 'package:face_validator/presentation/register/face_capture_page.dart';
import 'package:face_validator/services/auth/auth_exceptions.dart';
import 'package:face_validator/services/auth/auth_service.dart';
import 'package:face_validator/repositories/storage/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Homescreen extends StatefulWidget {
  Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final AuthService _authService = AuthService();

  final HiveService _hiveService = HiveService();

  Future<void> _validate(BuildContext context) async {
    try {
      final images = await Navigator.push<List<File>>(
        context,
        MaterialPageRoute(builder: (_) => const FaceCapturePage(totalShots: 1)),
      );

      if (images == null || images.isEmpty) return;

      final result = await _authService.validateUser(images.first);

      Fluttertoast.showToast(
        msg: result ? "Face Verified Successfully" : "Face Not Recognized",
      );
    } on BlurryImageException {
      Fluttertoast.showToast(msg: "Image is blurry. Hold still and try again.");
    } on NoFaceDetectedException {
      Fluttertoast.showToast(msg: "No face detected. Try again.");
    } on MultipleFacesException {
      Fluttertoast.showToast(
        msg: "Multiple faces detected. Only one person allowed.",
      );
    } catch (e) {
      log(e.toString());
      Fluttertoast.showToast(msg: "Validation failed: ${e.toString()}");
    }
  }

  FaceRegistrationModel? _user;

  Future<void> _loadUser() async {
    final email = await _hiveService.getLoggedInUser();
    if (email == null) return;
    final user = await _hiveService.getUserByEmail(email);
    if (!mounted) return;
    setState(() {
      _user = user;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await _hiveService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Face Validator",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _hiveService.clearUsers();
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top -
                    40,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.amber.shade100,
                            child: ClipOval(child: _buildProfileImage()),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Ready to validate your identity",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 8,
                          ),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "System Status",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text("Ready for face verification"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () => _validate(context),
                        icon: const Icon(Icons.face),
                        label: const Text(
                          "Validate Face",
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2C200),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_user == null) {
      return const Icon(Icons.person, size: 45, color: Colors.black54);
    }

    final imageFile = File(_user!.imagePath);

    if (!imageFile.existsSync()) {
      return const Icon(Icons.person, size: 45, color: Colors.black54);
    }

    return Image.file(
      imageFile,
      width: 84,
      height: 84,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const Icon(Icons.person, size: 45, color: Colors.black54);
      },
    );
  }
}
