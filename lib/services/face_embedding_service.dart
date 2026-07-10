import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmbeddingService {
  FaceEmbeddingService._internal();

  static final FaceEmbeddingService _instance =
      FaceEmbeddingService._internal();

  factory FaceEmbeddingService() => _instance;

  Interpreter? _interpreter;

  static const int _inputSize = 112;

  Future<void> loadModel() async {
    _interpreter ??=
        await Interpreter.fromAsset('assets/mobilefacenet.tflite');

    print("Input Shape : ${_interpreter!.getInputTensor(0).shape}");
    print("Output Shape: ${_interpreter!.getOutputTensor(0).shape}");
  }

  bool get isLoaded => _interpreter != null;

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  Future<List<double>> generateEmbedding(
    File croppedFace,
  ) async {
    if (_interpreter == null) {
      await loadModel();
    }

    final bytes = await croppedFace.readAsBytes();

    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception("Unable to decode image.");
    }

    final image = img.copyResize(
      decoded,
      width: _inputSize,
      height: _inputSize,
    );

    final input = _imageToTensor(image);

    final embeddingSize =
        _interpreter!.getOutputTensor(0).shape.last;

    final output = List.generate(
      1,
      (_) => List.filled(embeddingSize, 0.0),
    );

    _interpreter!.run(input, output);

    return _normalize(
      List<double>.from(output.first),
    );
  }

  List<List<List<List<double>>>> _imageToTensor(
    img.Image image,
  ) {
    final tensor = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (_) => List.generate(
          _inputSize,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);

        tensor[0][y][x][0] =
            (pixel.r - 127.5) / 128.0;

        tensor[0][y][x][1] =
            (pixel.g - 127.5) / 128.0;

        tensor[0][y][x][2] =
            (pixel.b - 127.5) / 128.0;
      }
    }

    return tensor;
  }

  List<double> _normalize(
    List<double> embedding,
  ) {
    double norm = 0;

    for (final value in embedding) {
      norm += value * value;
    }

    norm = sqrt(norm);

    if (norm == 0) {
      return embedding;
    }

    return embedding
        .map((e) => e / norm)
        .toList();
  }

  Future<List<double>> averageEmbeddings(
  List<List<double>> embeddings,
) async {
  if (embeddings.isEmpty) {
    throw Exception("No embeddings found.");
  }

  final length = embeddings.first.length;

  final average = List<double>.filled(
    length,
    0,
  );

  for (final embedding in embeddings) {
    for (int i = 0; i < length; i++) {
      average[i] += embedding[i];
    }
  }

  for (int i = 0; i < length; i++) {
    average[i] /= embeddings.length;
  }

  return _normalize(average);
}

Future<List<double>> generateAverageEmbedding(
  List<File> images,
) async {
  final embeddings = <List<double>>[];

  for (final image in images) {
    embeddings.add(
      await generateEmbedding(image),
    );
  }

  return averageEmbeddings(
    embeddings,
  );
}

Future<List<List<double>>> generateEmbeddings(
  List<File> images,
) async {
  final result = <List<double>>[];

  for (final image in images) {
    result.add(
      await generateEmbedding(image),
    );
  }

  return result;
}


}