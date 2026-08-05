import 'package:dio/dio.dart';

import 'package:frontend/core/network/api_constants.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/dio_factory.dart';
import 'package:frontend/core/storage/secure_storage.dart';

class AuthApiService {
  final ApiService _api = ApiService(DioFactory.getDio());

  /// Saves both the access token and refresh token securely.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await SecureStorage.saveAccessToken(accessToken);
    await SecureStorage.saveRefreshToken(refreshToken);
  }

  /// Checks whether the device has the tokens required for a saved session.
  Future<bool> isLoggedIn() async {
    final accessToken = await SecureStorage.getAccessToken();
    final refreshToken = await SecureStorage.getRefreshToken();

    return accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;
  }

  /// Clears the saved authentication session from the device.
  Future<void> logout() async {
    await SecureStorage.clear();
  }

  /// Requests a new access token using the saved refresh token.
  ///
  /// This uses a separate Dio instance so the refresh request does not pass
  /// through the normal access-token interceptor and cause a refresh loop.
  Future<String> refreshAccessToken() async {
    final refreshToken = await SecureStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('No refresh token was found');
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1),
      ),
    );

    final response = await refreshDio.post<dynamic>(
      ApiConstants.refresh,
      options: Options(
        headers: {
          // The Asalah backend expects the raw refresh token.
          // Do not add "Bearer" before it.
          'Authorization': refreshToken,
        },
      ),
    );

    final responseData = response.data;

    if (responseData is! Map) {
      throw const FormatException(
        'The refresh response is not a valid JSON object',
      );
    }

    final data = Map<String, dynamic>.from(responseData);
    final newAccessToken = data['access_token'];

    if (newAccessToken is! String || newAccessToken.isEmpty) {
      throw const FormatException(
        'The refresh response does not contain an access token',
      );
    }

    await SecureStorage.saveAccessToken(newAccessToken);

    return newAccessToken;
  }

  /// Logs in a parent and saves the returned tokens.
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.login({'email': email, 'password': password});

    final accessToken = response.data['access_token'];
    final refreshToken = response.data['refresh_token'];

    if (accessToken is! String || refreshToken is! String) {
      throw const FormatException(
        'The login response does not contain valid tokens',
      );
    }

    await saveTokens(accessToken: accessToken, refreshToken: refreshToken);

    return response;
  }

  /// Registers a parent and saves the returned tokens.
  Future<dynamic> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String guardianType,
  }) async {
    final response = await _api.register({
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'password': password,
      'guardian_type': guardianType,
    });

    final accessToken = response.data['access_token'];
    final refreshToken = response.data['refresh_token'];

    if (accessToken is! String || refreshToken is! String) {
      throw const FormatException(
        'The registration response does not contain valid tokens',
      );
    }

    await saveTokens(accessToken: accessToken, refreshToken: refreshToken);

    return response;
  }

  /// Logs in a child, saves the returned tokens, and stores child information.
  Future<dynamic> childLogin({required String accessCode}) async {
    final response = await _api.childLogin({'access_code': accessCode});

    final accessToken = response.data['access_token'];
    final refreshToken = response.data['refresh_token'];
    final childData = response.data['child'];

    if (accessToken is! String || refreshToken is! String) {
      throw const FormatException(
        'The child login response does not contain valid tokens',
      );
    }

    if (childData is! Map) {
      throw const FormatException(
        'The child login response does not contain valid child information',
      );
    }

    await saveTokens(accessToken: accessToken, refreshToken: refreshToken);

    await SecureStorage.saveChild(Map<String, dynamic>.from(childData));

    return response;
  }
}
