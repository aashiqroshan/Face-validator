import 'package:face_validator/models/face_registeration_model.dart';

abstract class FaceRepository {
  Future<void> registerUser(FaceRegistrationModel user);

  Future<List<FaceRegistrationModel>> getUsers();

  Future<FaceRegistrationModel?> getUserByEmail(
    String email,
  );

  Future<bool> isUserExists(
    String email,
  );

  Future<void> deleteUser(
    String id,
  );
}