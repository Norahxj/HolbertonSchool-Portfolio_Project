import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/child_model.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: "access_token", value: token);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: "refresh_token", value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: "access_token");
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: "refresh_token");
  }

  static Future<void> saveChild(Map<String, dynamic> child) async {
    await _storage.write(
      key: "child",
      value: jsonEncode(child),
    );
  }

  static Future<ChildModel?> getChild() async {
    final data = await _storage.read(key: "child");

    if (data == null) return null;

    return ChildModel.fromJson(
      jsonDecode(data),
    );
  }

  static Future<void> clearChild() async {
    await _storage.delete(key: "child");
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}