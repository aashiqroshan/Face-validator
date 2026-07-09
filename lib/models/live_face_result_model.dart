import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class LiveFaceResult {
  final bool hasFace;
  final bool hasSingleFace;
  final bool insideGuide;
  final bool lookingStraight;
  final bool eyesOpen;
  final bool faceLargeEnough;
  final bool readyToCapture;

  final String message;

  final Face? face;

  const LiveFaceResult({
    required this.hasFace,
    required this.hasSingleFace,
    required this.insideGuide,
    required this.lookingStraight,
    required this.eyesOpen,
    required this.faceLargeEnough,
    required this.readyToCapture,
    required this.message,
    this.face,
  });

  factory LiveFaceResult.initial() {
    return const LiveFaceResult(
      hasFace: false,
      hasSingleFace: false,
      insideGuide: false,
      lookingStraight: false,
      eyesOpen: false,
      faceLargeEnough: false,
      readyToCapture: false,
      message: "No Face",
    );
  }
}