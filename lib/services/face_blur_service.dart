import 'dart:io';
import 'package:image/image.dart' as img;

class FaceBlurService {
  double calculateSharpness(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) return 0;

    final gray = img.grayscale(image);
    final laplacians = <double>[];

    for (int y = 1; y < gray.height - 1; y++) {
      for (int x = 1; x < gray.width - 1; x++) {
        final c = gray.getPixel(x, y).r;
        final l = gray.getPixel(x - 1, y).r;
        final r = gray.getPixel(x + 1, y).r;
        final t = gray.getPixel(x, y - 1).r;
        final b = gray.getPixel(x, y + 1).r;
        laplacians.add(((4 * c) - l - r - t - b).toDouble());
      }
    }

    if (laplacians.isEmpty) return 0;
    final mean = laplacians.reduce((a, b) => a + b) / laplacians.length;
    final variance =
        laplacians.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
        laplacians.length;

    return variance;
  }

  bool isSharpEnough(File imageFile) {
    final sharpness = calculateSharpness(imageFile);
    print("Sharpness (variance) : $sharpness");
    return sharpness >= 40; // starting point — see note below
  }
}
