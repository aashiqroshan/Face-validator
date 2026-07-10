import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:face_validator/models/face_registeration_model.dart';
import 'package:face_validator/services/face_blur_service.dart';
import 'package:face_validator/services/face_crop_service.dart';
import 'package:face_validator/services/face_detector_service.dart';
import 'package:face_validator/services/face_embedding_service.dart';
import 'package:face_validator/services/storage/hive_service.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final FaceDetectorService _faceDetectorService = FaceDetectorService();
  final HiveService _hiveService = HiveService();
  final FaceCropService _cropService = FaceCropService();
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();
  final FaceBlurService _blurService = FaceBlurService();
  AuthService();

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
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
  required List<File> images,
}) async {
  final exists = await _hiveService.isEmailExists(email);
  if (exists) throw Exception("Email already exists");

  final allEmbeddings = <List<double>>[];
  File? firstCropped;
  FaceMetadata? firstMetadata;

  for (final image in images) {
    final metadata = await _faceDetectorService.extractMetadata(image);
    final face = await _cropService.detectFace(image);
    final cropped = await _cropService.cropFace(imageFile: image, face: face);

    if (!_blurService.isSharpEnough(cropped)) {
      throw Exception("One of the captures is blurry. Please retry registration.");
    }

    firstCropped ??= cropped;
    firstMetadata ??= metadata;

    final augmented = await _cropService.generateAugmentedFaces(cropped);
    final embeddings = await _embeddingService.generateEmbeddings(augmented);
    allEmbeddings.addAll(embeddings);
  }

  final user = FaceRegistrationModel(
    id: const Uuid().v4(),
    email: email,
    password: password,
    imagePath: images.first.path,
    croppedImagePath: firstCropped!.path,
    embeddings: allEmbeddings,
    metadata: firstMetadata!,
    registeredAt: DateTime.now(),
  );
  await _hiveService.saveUser(user);
  await _hiveService.saveLoggedInUser(user.email);
  return user;
}

  Future<bool> validateUser(File image) async {
    final email = await _hiveService.getLoggedInUser();

    if (email == null) {
      throw Exception("No logged in user.");
    }

    final registeredUser = await _hiveService.getUserByEmail(email);

    if (registeredUser == null) {
      throw Exception("User not found.");
    }

    final face = await _cropService.detectFace(image);

    final cropped = await _cropService.cropFace(imageFile: image, face: face);

    final sharp = _blurService.isSharpEnough(cropped);

    if (!sharp) {
      throw Exception("Image is blurry. Hold still and try again.");
    }

    final augmented = await _cropService.generateAugmentedFaces(cropped);

    final embeddings = await _embeddingService.generateEmbeddings(augmented);

    return compareEmbeddings(registeredUser.embeddings, embeddings);
  }

  bool compareEmbeddings(
    List<List<double>> storedEmbeddings,
    List<List<double>> currentEmbeddings,
  ) {
    final scores = <double>[];

    for (final stored in storedEmbeddings) {
      for (final current in currentEmbeddings) {
        scores.add(cosineSimilarity(stored, current));
      }
    }

    scores.sort((a, b) => b.compareTo(a));
    final bestThree = scores.take(3).toList();
    final average = bestThree.reduce((a, b) => a + b) / bestThree.length;

    print("Scores : $scores");
    print("Average Top 3 : $average");

    return average >= 0.75;
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return dot / (sqrt(normA) * sqrt(normB));
  }
}
