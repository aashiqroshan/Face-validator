import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_validator/models/live_face_result_model.dart';
import 'package:face_validator/services/face_alignment_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:face_validator/services/face_quality_service.dart';
import '../../models/face_registeration_model.dart';

class FaceDetectorService {
  final FaceQualityService _qualityService = FaceQualityService();
  final FaceAlignmentService _alignmentService = FaceAlignmentService();

  /// Used for final registration/validation image.
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: false,
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: false,
    ),
  );

  /// Used only for live preview.
  final FaceDetector _liveFaceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableContours: false,
      enableClassification: false,
      enableLandmarks: true,
      enableTracking: false,
    ),
  );

  Future<FaceMetadata> extractMetadata(File image) async {
    final inputImage = InputImage.fromFile(image);

    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      log("No face detected.");
      throw Exception("No face detected.");
    }

    if (faces.length > 1) {
      log("Multiple faces detected.");
      throw Exception("Multiple faces detected.");
    }

    final face = faces.first;

    return FaceMetadata(
      headEulerAngleX: face.headEulerAngleX ?? 0,
      headEulerAngleY: face.headEulerAngleY ?? 0,
      headEulerAngleZ: face.headEulerAngleZ ?? 0,
      smilingProbability: face.smilingProbability ?? 0,
      leftEyeOpenProbability: face.leftEyeOpenProbability ?? 0,
      rightEyeOpenProbability: face.rightEyeOpenProbability ?? 0,
      boundingBox: FaceBoundingBox(
        left: face.boundingBox.left,
        top: face.boundingBox.top,
        right: face.boundingBox.right,
        bottom: face.boundingBox.bottom,
      ),
    );
  }

  Future<LiveFaceResult> detectLiveFace({
    required InputImage inputImage,
    required CameraImage cameraImage,
    required Size previewSize,
  }) async {
    final faces = await _liveFaceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      return LiveFaceResult(
        hasFace: false,
        hasSingleFace: false,
        insideGuide: false,
        faceLargeEnough: false,
        lookingStraight: false,
        eyesVisible: false,
        enoughLighting: false,
        stable: false,
        qualityScore: 0,
        readyToCapture: false,
        message: "No face detected",
      );
    }

    if (faces.length > 1) {
      return LiveFaceResult(
        hasFace: true,
        hasSingleFace: false,
        insideGuide: false,
        faceLargeEnough: false,
        lookingStraight: false,
        eyesVisible: false,
        enoughLighting: false,
        stable: false,
        qualityScore: 0,
        readyToCapture: false,
        message: "Multiple faces detected",
      );
    }

    final face = faces.first;
    final alignmentMessage =
    _alignmentService.getAlignmentMessage(
      faceBox: face.boundingBox,
      previewSize: previewSize,
    );

    

    final insideGuide = _qualityService.isInsideGuide(
      face.boundingBox,
      previewSize,
    );

    final faceLargeEnough = _qualityService.isFaceLargeEnough(
      face.boundingBox,
      previewSize,
    );

    final lookingStraight = _qualityService.isLookingStraight(face);

    final eyesVisible =
        face.landmarks[FaceLandmarkType.leftEye] != null &&
        face.landmarks[FaceLandmarkType.rightEye] != null;

    final enoughLighting = _qualityService.hasEnoughLighting(
      cameraImage.planes.first.bytes,
    );
    final stable = true;

    final qualityScore = _qualityService.calculateQualityScore(
      insideGuide: insideGuide,
      faceLargeEnough: faceLargeEnough,
      lookingStraight: lookingStraight,
      eyesVisible: eyesVisible,
      enoughLighting: enoughLighting
    );

    print(
  'DBG previewSize=$previewSize faceBox=${face.boundingBox} '
  'insideGuide=$insideGuide faceLargeEnough=$faceLargeEnough '
  'lookingStraight=$lookingStraight eyesVisible=$eyesVisible '
  'enoughLighting=$enoughLighting qualityScore=$qualityScore '
  'alignmentMessage=$alignmentMessage',
);

    final readyToCapture =
    alignmentMessage == null &&
    lookingStraight &&
    eyesVisible &&
    enoughLighting &&
    qualityScore >= 90;

    String message;

if (alignmentMessage != null) {
  message = alignmentMessage;
} else if (!lookingStraight) {
  message = "Look Straight";
} else if (!eyesVisible) {
  message = "Open Both Eyes";
} else if (!enoughLighting) {
  message = "Improve Lighting";
} else {
  message = "Ready";
}

    return LiveFaceResult(
      hasFace: true,
      hasSingleFace: true,
      insideGuide: insideGuide,
      faceLargeEnough: faceLargeEnough,
      lookingStraight: lookingStraight,
      eyesVisible: eyesVisible,
      enoughLighting: enoughLighting,
      stable: stable,
      qualityScore: qualityScore,
      readyToCapture: readyToCapture,
      message: message,
      face: face,
    );
  }

  void dispose() {
    _faceDetector.close();
    _liveFaceDetector.close();
  }

  bool hasEnoughLighting(Uint8List bytes) {
    if (bytes.isEmpty) {
      return false;
    }

    double total = 0;

    for (final value in bytes) {
      total += value;
    }

    final average = total / bytes.length;

    print("Brightness : $average");

    return average >= 70;
  }
}
