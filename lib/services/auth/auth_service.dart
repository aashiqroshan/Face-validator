import 'dart:developer';
import 'dart:io';

import 'package:face_validator/models/face_registeration_model.dart';
import 'package:face_validator/services/face_detector_service.dart';
import 'package:face_validator/services/storage/hive_service.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final FaceDetectorService _faceDetectorService = FaceDetectorService();
   final HiveService _hiveService = HiveService();
    AuthService();



  Future<bool> loginUser({required String email,required String password,}) async {
    final user = await _hiveService.getUserByEmail(email);
    if (user == null) {
      throw Exception("User not found");
    }
    if (user.password != password) {
      throw Exception("Invalid password");
    }

    await _hiveService.saveLoggedInUser(user.email);
    return true;
  }

  Future<FaceRegistrationModel> registerUser({
    required String email,
    required String password,
    required File image,
  }) async {

    final exists = await _hiveService.isEmailExists(email);

    if (exists) {
      throw Exception("Email already exists");
    }


    final metadata =
        await _faceDetectorService.extractMetadata(image);


    final embedding = <double>[];

    final user = FaceRegistrationModel(
      id: const Uuid().v4(),
      email: email,
      password: password,
      imagePath: image.path,
      embedding: embedding,
      metadata: metadata,
      registeredAt: DateTime.now(),
    );
    await _hiveService.saveUser(user);
    await _hiveService.saveLoggedInUser(user.email);

    return user;
  }

Future<bool> validateUser(File image) async {
  final users = await _hiveService.getUsers();

  if (users.isEmpty) {
    log('zzrrr No registered user.');
    throw Exception("No registered user.");
  }

  /// Since only one user is being validated for now
  final registeredUser = users.first;

  final currentMetadata =
      await _faceDetectorService.extractMetadata(image);

  return _compareMetadata(
    registeredUser.metadata,
    currentMetadata,
  );
}


bool _compareMetadata(
  FaceMetadata registered,
  FaceMetadata current,
) {
  const double threshold = 8;

  final x =
      (registered.headEulerAngleX - current.headEulerAngleX)
          .abs();

  final y =
      (registered.headEulerAngleY - current.headEulerAngleY)
          .abs();

  final z =
      (registered.headEulerAngleZ - current.headEulerAngleZ)
          .abs();

  if (x > threshold) return false;

  if (y > threshold) return false;

  if (z > threshold) return false;

  return true;
}
}