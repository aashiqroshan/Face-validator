import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class LiveFaceResult {
  final bool hasFace;
  final bool hasSingleFace;

  final bool insideGuide;
  final bool faceLargeEnough;

  final bool lookingStraight;
  final bool eyesVisible;
  final bool enoughLighting;
  final bool stable;

  final double qualityScore;

  final bool readyToCapture;

  final String message;

  final Face? face;

  const LiveFaceResult({
    required this.hasFace,
    required this.hasSingleFace,
    required this.insideGuide,
    required this.faceLargeEnough,
    required this.lookingStraight,
    required this.eyesVisible,
    required this.enoughLighting,
    required this.stable,
    required this.qualityScore,
    required this.readyToCapture,
    required this.message,
    this.face,
  });

  factory LiveFaceResult.initial() {
    return const LiveFaceResult(
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
      message: "Align your face",
    );
  }

  LiveFaceResult copyWith({
  bool? hasFace,
  bool? hasSingleFace,
  bool? insideGuide,
  bool? faceLargeEnough,
  bool? lookingStraight,
  bool? eyesVisible,
  bool? enoughLighting,
  bool? stable,
  double? qualityScore,
  bool? readyToCapture,
  String? message,
  Face? face,
}) {
  return LiveFaceResult(
    hasFace: hasFace ?? this.hasFace,
    hasSingleFace: hasSingleFace ?? this.hasSingleFace,
    insideGuide: insideGuide ?? this.insideGuide,
    faceLargeEnough:
        faceLargeEnough ?? this.faceLargeEnough,
    lookingStraight:
        lookingStraight ?? this.lookingStraight,
    eyesVisible: eyesVisible ?? this.eyesVisible,
    enoughLighting:
        enoughLighting ?? this.enoughLighting,
    stable: stable ?? this.stable,
    qualityScore:
        qualityScore ?? this.qualityScore,
    readyToCapture:
        readyToCapture ?? this.readyToCapture,
    message: message ?? this.message,
    face: face ?? this.face,
  );
}
}