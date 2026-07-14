import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceQualityService {
  static const double _guideWidth = 300;
  static const double _guideHeight = 540;

  bool isInsideGuide(Rect faceBox, Size previewSize) {
    final guide = Rect.fromCenter(
      center: Offset(previewSize.width / 2, previewSize.height * .48),
      width: _guideWidth,
      height: _guideHeight,
    );

    final faceCenter = faceBox.center;

    return guide.contains(faceCenter);
  }

  bool isFaceLargeEnough(Rect faceBox, Size previewSize) {
    final guideArea = _guideWidth * _guideHeight;

    final faceArea = faceBox.width * faceBox.height;

    final occupancy = faceArea / guideArea;

    return occupancy >= 0.18;
  }

  bool isLookingStraight(Face face) {
    final yaw = face.headEulerAngleY ?? 999;

    final pitch = face.headEulerAngleX ?? 999;

    final roll = face.headEulerAngleZ ?? 999;

    const tolerance = 10.0;

    return yaw.abs() <= tolerance &&
        pitch.abs() <= tolerance &&
        roll.abs() <= tolerance;
  }

  double calculateQualityScore({
    required bool insideGuide,
    required bool faceLargeEnough,
    required bool lookingStraight,
    required bool eyesVisible,
    required bool enoughLighting,
  }) {
    double score = 0;

    if (insideGuide) score += 20;
    if (faceLargeEnough) score += 20;
    if (lookingStraight) score += 20;
    if (eyesVisible) score += 15;
    if (enoughLighting) score += 15;

    return score;
  }

  bool hasEnoughLighting(Uint8List bytes) {
    if (bytes.isEmpty) {
      return false;
    }

    int total = 0;

    for (int i = 0; i < bytes.length; i += 4) {
      final r = bytes[i];
      final g = bytes[i + 1];
      final b = bytes[i + 2];

      final brightness = (0.299 * r + 0.587 * g + 0.114 * b);

      total += brightness.round();
    }

    final avg = total / (bytes.length / 4);

    print("Brightness : $avg");

    return avg >= 70 && avg <= 200;
  }
}
