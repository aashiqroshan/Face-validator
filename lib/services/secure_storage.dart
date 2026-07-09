import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  final String registerUser= "registered_user";

  Future<void> saveUser(String json) async {
    await _storage.write(
      key: registerUser,
      value: json,
    );
  }

  Future<String?> getUser() async {
    return await _storage.read(
      key: registerUser,
    );
  }

  Future<void> clear() async {
    await _storage.delete(
      key: registerUser,
    );
  }
}