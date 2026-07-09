import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  Future<String> saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();

    final imageDirectory =
        Directory("${directory.path}/face_images");

    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }

    final fileName =
        "face_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final savedImage = await image.copy(
      join(imageDirectory.path, fileName),
    );

    return savedImage.path;
  }
}