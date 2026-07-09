import 'package:flutter/material.dart';

class FaceRegistrationModel {
  final String id;
  final String email;
  final String password;
  final String imagePath;
  final List<double> embedding;
  final FaceMetadata metadata;

  final DateTime registeredAt;

  const FaceRegistrationModel({
    required this.id,
    required this.email,
    required this.password,
    required this.imagePath,
    required this.embedding,
    required this.metadata,
    required this.registeredAt,
  });

  FaceRegistrationModel copyWith({
    String? id,
    String? email,
    String? imagePath,
    String? password,
    List<double>? embedding,
    FaceMetadata? metadata,
    DateTime? registeredAt,
  }) {
    return FaceRegistrationModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      imagePath: imagePath ?? this.imagePath,
      embedding: embedding ?? this.embedding,
      metadata: metadata ?? this.metadata,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "password": password,
      "imagePath": imagePath,
      "embedding": embedding,
      "metadata": metadata.toJson(),
      "registeredAt": registeredAt.toIso8601String(),
    };
  }

  factory FaceRegistrationModel.fromJson(Map<String, dynamic> json) {
    return FaceRegistrationModel(
      id: json["id"],
      email: json["email"],
      password: json["password"],
      imagePath: json["imagePath"],
      embedding: List<double>.from(json["embedding"]),
      metadata: FaceMetadata.fromJson(Map<String, dynamic>.from(json["metadata"]),),
      registeredAt: DateTime.parse(json["registeredAt"]),
    );
  }
}

class FaceMetadata {
  final double headEulerAngleX;
  final double headEulerAngleY;
  final double headEulerAngleZ;
  final double smilingProbability;
  final double leftEyeOpenProbability;
  final double rightEyeOpenProbability;
  final FaceBoundingBox boundingBox;

  const FaceMetadata({
    required this.headEulerAngleX,
    required this.headEulerAngleY,
    required this.headEulerAngleZ,
    required this.smilingProbability,
    required this.leftEyeOpenProbability,
    required this.rightEyeOpenProbability,
    required this.boundingBox,
  });

  FaceMetadata copyWith({
    double? headEulerAngleX,
    double? headEulerAngleY,
    double? headEulerAngleZ,
    double? smilingProbability,
    double? leftEyeOpenProbability,
    double? rightEyeOpenProbability,
    FaceBoundingBox? boundingBox,
  }) {
    return FaceMetadata(
      headEulerAngleX: headEulerAngleX ?? this.headEulerAngleX,
      headEulerAngleY: headEulerAngleY ?? this.headEulerAngleY,
      headEulerAngleZ: headEulerAngleZ ?? this.headEulerAngleZ,
      smilingProbability: smilingProbability ?? this.smilingProbability,
      leftEyeOpenProbability: leftEyeOpenProbability ?? this.leftEyeOpenProbability,
      rightEyeOpenProbability: rightEyeOpenProbability ?? this.rightEyeOpenProbability,
      boundingBox: boundingBox ?? this.boundingBox,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "headEulerAngleX": headEulerAngleX,
      "headEulerAngleY": headEulerAngleY,
      "headEulerAngleZ": headEulerAngleZ,
      "smilingProbability": smilingProbability,
      "leftEyeOpenProbability": leftEyeOpenProbability,
      "rightEyeOpenProbability": rightEyeOpenProbability,
      "boundingBox": boundingBox.toJson(),
    };
  }

  factory FaceMetadata.fromJson(Map<String, dynamic> json) {
    return FaceMetadata(
      headEulerAngleX:
          (json["headEulerAngleX"] as num).toDouble(),
      headEulerAngleY:
          (json["headEulerAngleY"] as num).toDouble(),
      headEulerAngleZ:
          (json["headEulerAngleZ"] as num).toDouble(),
      smilingProbability:
          (json["smilingProbability"] as num).toDouble(),
      leftEyeOpenProbability:
          (json["leftEyeOpenProbability"] as num).toDouble(),
      rightEyeOpenProbability:
          (json["rightEyeOpenProbability"] as num).toDouble(),
      boundingBox: FaceBoundingBox.fromJson(Map<String, dynamic>.from(json["boundingBox"],),),
    );
  }
}

class FaceBoundingBox {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const FaceBoundingBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double get width => right - left;

  double get height => bottom - top;

  Map<String, dynamic> toJson() {
    return {
      "left": left,
      "top": top,
      "right": right,
      "bottom": bottom,
    };
  }

  factory FaceBoundingBox.fromJson(
      Map<String, dynamic> json) {
    return FaceBoundingBox(
      left: (json["left"] as num).toDouble(),
      top: (json["top"] as num).toDouble(),
      right: (json["right"] as num).toDouble(),
      bottom: (json["bottom"] as num).toDouble(),
    );
  }

  FaceBoundingBox copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return FaceBoundingBox(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
    );
  }
}