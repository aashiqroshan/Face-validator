class BlurryImageException implements Exception {
  final String message;
  BlurryImageException([
    this.message = "Image is blurry. Hold still and try again.",
  ]);
  @override
  String toString() => message;
}

class NoFaceDetectedException implements Exception {
  final String message;
  NoFaceDetectedException([this.message = "No face detected."]);
  @override
  String toString() => message;
}

class MultipleFacesException implements Exception {
  final String message;
  MultipleFacesException([this.message = "Multiple faces detected."]);
  @override
  String toString() => message;
}
