import 'dart:developer';
import 'dart:io';

import 'package:face_validator/models/live_face_result_model.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../models/face_registeration_model.dart';

class FaceDetectorService {
  // Accurate detector - used only for the final captured still image.
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: false,
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: false,
    ),
  );

  // Lightweight detector - used for the live camera stream.
  // 'fast' mode + no landmarks/classification keeps per-frame cost low so
  // it can keep pace with incoming frames instead of backing up the
  // native image buffer (which is what was throwing "Getting Image failed").
  final FaceDetector _liveFaceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableContours: false,
      enableClassification: false,
      enableLandmarks: false,
      enableTracking: false,
    ),
  );

  Future<FaceMetadata> extractMetadata(File image) async {
    final inputImage = InputImage.fromFile(image);

    final faces = await _faceDetector.processImage(inputImage);

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

  void dispose() {
    _faceDetector.close();
    _liveFaceDetector.close();
  }

  Future<LiveFaceResult> detectLiveFace({
    required InputImage inputImage,
    required Size previewSize,
  }) async {
    final faces = await _liveFaceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      return LiveFaceResult(
        hasFace: false,
        hasSingleFace: false,
        faceLargeEnough: false,
        lookingStraight: false,
        eyesOpen: false,
        insideGuide: false,
        readyToCapture: false,
        message: "No face detected",
      );
    }

    if (faces.length > 1) {
      return LiveFaceResult(
        hasFace: true,
        hasSingleFace: false,
        faceLargeEnough: false,
        lookingStraight: false,
        eyesOpen: false,
        insideGuide: false,
        readyToCapture: false,
        message: "Multiple faces detected",
      );
    }

    final face = faces.first;

    return LiveFaceResult(
      hasFace: true,
      hasSingleFace: true,
      faceLargeEnough: false,
      lookingStraight: false,
      eyesOpen: false,
      insideGuide: false,
      readyToCapture: false,
      message: "Face detected",
      face: face,
    );
  }
}