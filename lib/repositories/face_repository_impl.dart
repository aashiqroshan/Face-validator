import 'package:face_validator/models/face_registeration_model.dart';

import '../services/storage/hive_service.dart';
import 'face_repository.dart';

class FaceRepositoryImpl extends FaceRepository {
  final HiveService hiveService;

  FaceRepositoryImpl(this.hiveService);

  @override
  Future<void> registerUser(
    FaceRegistrationModel user,
  ) async {
    await hiveService.put(
      user.id,
      user.toJson(),
    );
  }

  @override
  Future<List<FaceRegistrationModel>> getUsers() async {
    final data = await hiveService.getAll();

    return data
        .map(
          (e) => FaceRegistrationModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  @override
  Future<FaceRegistrationModel?> getUserByEmail(
    String email,
  ) async {
    final users = await getUsers();

    try {
      return users.firstWhere(
        (e) => e.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isUserExists(
    String email,
  ) async {
    return (await getUserByEmail(email)) != null;
  }

  @override
  Future<void> deleteUser(
    String id,
  ) async {
    await hiveService.delete(id);
  }
}