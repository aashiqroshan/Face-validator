import 'package:flutter/material.dart';

class FaceAlignmentService {
  static const double _positionTolerance = 25;
  static const double _sizeTolerance = 0.55;

  String? getAlignmentMessage({
    required Rect faceBox,
    required Size previewSize,
  }) {
    final guideCenter = Offset(previewSize.width / 2, previewSize.height * .48);

    final faceCenter = faceBox.center;

    final dx = faceCenter.dx - guideCenter.dx;
    final dy = faceCenter.dy - guideCenter.dy;

    if (dx < -_positionTolerance) {
      return "Move Right";
    }

    if (dx > _positionTolerance) {
      return "Move Left";
    }

    if (dy < -_positionTolerance) {
      return "Move Down";
    }

    if (dy > _positionTolerance) {
      return "Move Up";
    }

    final faceRatio = faceBox.height / 540;

    if (faceRatio < _sizeTolerance) {
      return "Move Closer";
    }

    if (faceRatio > .95) {
      return "Move Back";
    }

    return null;
  }
}
