import 'package:dio/dio.dart';

import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/dio_factory.dart';
import 'package:frontend/core/storage/secure_storage.dart';

class AuthApiService {
  final ApiService _api = ApiService(DioFactory.getDio());

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await SecureStorage.saveAccessToken(accessToken);
    await SecureStorage.saveRefreshToken(refreshToken);
  }

  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getAccessToken();

    print("loaded token = $token");
    return token != null;
  }

  Future<void> logout() async {
    await SecureStorage.clear();
  }

  // Refresh access token
  Future<String> refreshAccessToken() async {
    final refreshToken = await SecureStorage.getRefreshToken();

    final dio = Dio(
      BaseOptions(
        baseUrl: DioFactory.getDio().options.baseUrl,
      ),
    );

    final response = await dio.post(
      '/auth/refresh',
      options: Options(
        headers: {
          "Authorization": refreshToken,
        },
      ),
    );

    final newAccessToken = response.data["access_token"];

    await SecureStorage.saveAccessToken(newAccessToken);

    return newAccessToken;
  }

  // Parent login
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.login({
      'email': email,
      'password': password,
    });

    await saveTokens(
      accessToken: response.data['access_token'],
      refreshToken: response.data['refresh_token'],
    );

    return response;
  }

  // Parent register
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

    await saveTokens(
      accessToken: response.data['access_token'],
      refreshToken: response.data['refresh_token'],
    );

    return response;
  }

  // Child login
Future<dynamic> childLogin({
  required String accessCode,
}) async {
  final response = await _api.childLogin({
    'access_code': accessCode,
  });

  await saveTokens(
    accessToken: response.data['access_token'],
    refreshToken: response.data['refresh_token'],
  );

  await SecureStorage.saveChild(
    response.data['child'],
  );

  return response;
}
}