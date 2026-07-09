import 'dart:io';

import 'package:face_validator/models/face_registeration_model.dart';
import 'package:face_validator/services/face_repo.dart';

class FaceRecognitionService {
  // FaceRecognitionService({
  //   required this.repository,
  // });

  // final FaceRepository repository;

  // Future<FaceRegistrationModel> registerUser({
  //   required String password,
  //   required String email,
  //   required File image,
  // }) async {
  //   /// 1. Detect Face
  //   final detectedFace = await _detectFace(image);

  //   if (detectedFace == null) {
  //     throw Exception("No face detected.");
  //   }

  //   /// 2. Validate Face Quality
  //   final isValid = await _validateFace(detectedFace);

  //   if (!isValid) {
  //     throw Exception("Face quality is not sufficient.");
  //   }

  //   /// 3. Crop Face
  //   final croppedFace = await _cropFace(
  //     image,
  //     detectedFace,
  //   );

  //   /// 4. Generate Embedding
  //   final embedding = await _generateEmbedding(
  //     croppedFace,
  //   );

  //   /// 6. Build Model
  //   // final model = FaceRegistrationModel();
  //   //   id: DateTime.now().millisecondsSinceEpoch.toString(),
  //   //   password: password,
  //   //   email: email,
  //   //   imagePath: imagePath,
  //   //   embedding: embedding,
  //   //   metadata: detectedFace.metadata,
  //   //   registeredAt: DateTime.now(),
  //   // );

  //   return model;
  // }

  Future<dynamic> _detectFace(File image) async {
    throw UnimplementedError();
  }

  Future<bool> _validateFace(dynamic face) async {
    throw UnimplementedError();
  }

  Future<File> _cropFace(
    File image,
    dynamic face,
  ) async {
    throw UnimplementedError();
  }

  Future<List<double>> _generateEmbedding(
    File image,
  ) async {
    throw UnimplementedError();
  }
}