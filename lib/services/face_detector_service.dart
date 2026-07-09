import 'dart:developer';
import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../models/face_registeration_model.dart';

class FaceDetectorService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: false,
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: false,
    ),
  );

  Future<FaceMetadata> extractMetadata(
    File image,
  ) async {
    final inputImage = InputImage.fromFile(image);

    final faces =
        await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      log('zzrrr No face detected.');
      throw Exception("No face detected.");
    }

    if (faces.length > 1) {
      log('zzrrr Multiple faces detected.');
      throw Exception("Multiple faces detected.");
    }

    final face = faces.first;

    return FaceMetadata(
      headEulerAngleX: face.headEulerAngleX ?? 0,
      headEulerAngleY: face.headEulerAngleY ?? 0,
      headEulerAngleZ: face.headEulerAngleZ ?? 0,

      smilingProbability:
          face.smilingProbability ?? 0,

      leftEyeOpenProbability:
          face.leftEyeOpenProbability ?? 0,

      rightEyeOpenProbability:
          face.rightEyeOpenProbability ?? 0,

      boundingBox: FaceBoundingBox(
        left: face.boundingBox.left,
        top: face.boundingBox.top,
        right: face.boundingBox.right,
        bottom: face.boundingBox.bottom,
      ),
    );
  }

  void dispose() {
    _faceDetector.close();
  }
}