import 'package:face_validator/models/face_registeration_model.dart';
import 'package:hive/hive.dart';

class HiveService {
  static const String userBox = "users";
  static const String settingsBox = "settings";
  static const String loggedInUserKey = "loggedInUser";

  Future<Box> openSettingsBox() async {
    if (!Hive.isBoxOpen(settingsBox)) {
      return await Hive.openBox(settingsBox);
    }
    return Hive.box(settingsBox);
  }

  Future<Box> openUserBox() async {
    if (!Hive.isBoxOpen(userBox)) {
      return await Hive.openBox(userBox);
    }
    return Hive.box(userBox);
  }

  Future<void> put(String key, dynamic value) async {
    final box = await openUserBox();
    await box.put(key, value);
  }

  Future<dynamic> get(String key) async {
    final box = await openUserBox();
    return box.get(key);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final box = await openUserBox();
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> delete(String key) async {
    final box = await openUserBox();
    await box.delete(key);
  }

  /// Save User
  Future<void> saveUser(FaceRegistrationModel user) async {
    await put(user.id, user.toJson());
  }

  /// Get All Users
  Future<List<FaceRegistrationModel>> getUsers() async {
    final users = await getAll();
    return users
        .map(
          (e) => FaceRegistrationModel.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<void> saveLoggedInUser(String email) async {
    final box = await openSettingsBox();
    await box.put(loggedInUserKey, email);
  }

  Future<String?> getLoggedInUser() async {
    final box = await openSettingsBox();
    return box.get(loggedInUserKey);
  }

  Future<void> logout() async {
    final box = await openSettingsBox();
    await box.delete(loggedInUserKey);
  }

  /// Check Duplicate Email
  Future<bool> isEmailExists(String email) async {
    final users = await getUsers();

    return users.any((user) => user.email.toLowerCase() == email.toLowerCase());
  }

  /// Get User By Email
  Future<FaceRegistrationModel?> getUserByEmail(String email) async {
    final users = await getUsers();

    try {
      return users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Delete User
  Future<void> deleteUser(String id) async {
    await delete(id);
  }

  /// Clear All Users
  Future<void> clearUsers() async {
    final box = await openUserBox();
    await box.clear();
  }
}
