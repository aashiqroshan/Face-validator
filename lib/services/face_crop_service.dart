import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class FaceCropService {
  Future<Face> detectFace(File imageFile) async {
    final detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableClassification: true,
      ),
    );

    final inputImage = InputImage.fromFile(imageFile);
    final faces = await detector.processImage(inputImage);
    detector.close();

    if (faces.isEmpty) {
      throw Exception("No face detected.");
    }

    // Pick the largest face instead of failing outright — spurious small
    // detections (e.g. from rotation padding) are filtered out this way.
    faces.sort(
      (a, b) => (b.boundingBox.width * b.boundingBox.height).compareTo(
        a.boundingBox.width * a.boundingBox.height,
      ),
    );

    return faces.first;
  }

  Future<File> cropFace({required File imageFile, required Face face}) async {
    final raw = await cropFaceRaw(imageFile: imageFile, face: face);
    return resizeForModel(raw);
  }

  Future<File> cropFaceRaw({
    required File imageFile,
    required Face face,
  }) async {
    final bytes = await imageFile.readAsBytes();
    var originalImage = img.decodeImage(bytes);
    if (originalImage == null) throw Exception("Unable to decode image.");
    originalImage = img.bakeOrientation(originalImage);

    final alignedImage = rotateImage(originalImage, face);
    final alignedFace = await detectFaceFromDecodedImage(alignedImage);
    final cropRect = buildFaceCropRect(alignedFace, alignedImage);

    final cropped = img.copyCrop(
      alignedImage,
      x: cropRect.left.round(),
      y: cropRect.top.round(),
      width: cropRect.width.round(),
      height: cropRect.height.round(),
    );

    final croppedFile = File(
      imageFile.path.replaceFirst(".jpg", "_cropped_raw.jpg"),
    );
    await croppedFile.writeAsBytes(img.encodeJpg(cropped, quality: 95));
    return croppedFile;
  }

  Future<File> resizeForModel(File croppedFile) async {
    final bytes = await croppedFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception("Unable to decode image.");

    final resized = img.copyResize(
      image,
      width: 112,
      height: 112,
      interpolation: img.Interpolation.linear,
    );

    final file = File(
      croppedFile.path.replaceFirst("_cropped_raw.jpg", "_cropped.jpg"),
    );
    await file.writeAsBytes(img.encodeJpg(resized, quality: 95));
    return file;
  }

  img.Image rotateImage(img.Image image, Face face) {
    final leftEye = face.landmarks[FaceLandmarkType.leftEye]?.position;

    final rightEye = face.landmarks[FaceLandmarkType.rightEye]?.position;

    if (leftEye == null || rightEye == null) {
      return image;
    }

    final angle =
        atan2(rightEye.y - leftEye.y, rightEye.x - leftEye.x) * 180 / pi;

    return img.copyRotate(
      image,
      angle: -angle,
      interpolation: img.Interpolation.linear,
    );
  }

  Future<Face> detectFaceFromDecodedImage(img.Image image) async {
    final temp = File("${Directory.systemTemp.path}/aligned_face.jpg");

    await temp.writeAsBytes(img.encodeJpg(image));

    return detectFace(temp);
  }

  Rect buildFaceCropRect(Face face, img.Image image) {
    final leftEye = face.landmarks[FaceLandmarkType.leftEye]?.position;

    final rightEye = face.landmarks[FaceLandmarkType.rightEye]?.position;

    if (leftEye == null || rightEye == null) {
      return face.boundingBox;
    }

    final eyeCenter = Offset(
      (leftEye.x + rightEye.x) / 2,
      (leftEye.y + rightEye.y) / 2,
    );

    final eyeDistance = sqrt(
      pow(rightEye.x - leftEye.x, 2) + pow(rightEye.y - leftEye.y, 2),
    );

    /// Tune this later.
    final cropSize = eyeDistance * 2.8;

    double left = eyeCenter.dx - cropSize / 2;

    double top = eyeCenter.dy - cropSize * 0.42;

    left = left.clamp(0.0, image.width - cropSize);

    top = top.clamp(0.0, image.height - cropSize);

    return Rect.fromLTWH(left, top, cropSize, cropSize);
  }

  Future<List<File>> generateAugmentedFaces(File croppedFace) async {
    final bytes = await croppedFace.readAsBytes();

    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Unable to decode image.");
    }

    final images = <img.Image>[
      image,

      // Slight rotations
      img.copyRotate(image, angle: -5),
      img.copyRotate(image, angle: 5),

      // Slight zoom in
      img.copyResizeCropSquare(
        img.copyResize(image, width: 120, height: 120),
        size: 112,
      ),

      // Slight translation
      img.copyCrop(image, x: 2, y: 2, width: 110, height: 110),
    ];

    final files = <File>[];

    for (int i = 0; i < images.length; i++) {
      final resized = img.copyResize(images[i], width: 112, height: 112);

      final file = File(croppedFace.path.replaceFirst(".jpg", "_aug_$i.jpg"));

      await file.writeAsBytes(img.encodeJpg(resized, quality: 95));

      files.add(file);
    }

    return files;
  }

  Future<File> _saveImage(img.Image image, File original, String suffix) async {
    final resized = img.copyResize(
      image,
      width: 112,
      height: 112,
      interpolation: img.Interpolation.linear,
    );

    final file = File(original.path.replaceFirst(".jpg", "$suffix.jpg"));

    await file.writeAsBytes(img.encodeJpg(resized, quality: 95));

    return file;
  }
}
