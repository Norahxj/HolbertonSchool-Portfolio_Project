import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/child_model.dart';

class SecureStorage {
  SecureStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _childKey = 'child';

  static bool _isInitialized = false;

  static String? _accessToken;
  static String? _refreshToken;
  static ChildModel? _child;

  /// Loads saved authentication data once when the app starts.
  ///
  /// After this, API requests can read the access token from memory instead
  /// of reading secure storage before every request.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final values = await Future.wait<String?>([
        _storage.read(key: _accessTokenKey),
        _storage.read(key: _refreshTokenKey),
        _storage.read(key: _childKey),
      ]);

      _accessToken = values[0];
      _refreshToken = values[1];
      _child = _decodeChild(values[2]);
    } catch (_) {
      _accessToken = null;
      _refreshToken = null;
      _child = null;
    }

    _isInitialized = true;
  }

  /// Fast in-memory access for Dio requests.
  static String? get cachedAccessToken => _accessToken;

  static Future<void> saveAccessToken(String token) async {
    await _ensureInitialized();

    await _storage.write(
      key: _accessTokenKey,
      value: token,
    );

    _accessToken = token;
  }

  static Future<void> saveRefreshToken(String token) async {
    await _ensureInitialized();

    await _storage.write(
      key: _refreshTokenKey,
      value: token,
    );

    _refreshToken = token;
  }

  static Future<String?> getAccessToken() async {
    await _ensureInitialized();
    return _accessToken;
  }

  static Future<String?> getRefreshToken() async {
    await _ensureInitialized();
    return _refreshToken;
  }

  static Future<void> saveChild(Map<String, dynamic> child) async {
    await _ensureInitialized();

    await _storage.write(
      key: _childKey,
      value: jsonEncode(child),
    );

    _child = ChildModel.fromJson(child);
  }

  static Future<ChildModel?> getChild() async {
    await _ensureInitialized();
    return _child;
  }

  static Future<void> clearChild() async {
    await _ensureInitialized();

    await _storage.delete(key: _childKey);
    _child = null;
  }

  static Future<void> clear() async {
    await _ensureInitialized();

    await _storage.deleteAll();

    _accessToken = null;
    _refreshToken = null;
    _child = null;
  }

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  static ChildModel? _decodeChild(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is Map<String, dynamic>) {
        return ChildModel.fromJson(decoded);
      }

      if (decoded is Map) {
        return ChildModel.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
