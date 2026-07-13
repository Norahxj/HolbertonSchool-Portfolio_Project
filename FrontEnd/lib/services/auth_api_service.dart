import 'package:dio/dio.dart';
import '../core/network/api_constants.dart';
import '../core/network/dio_factory.dart';
import '../core/storage/secure_storage.dart';

class AuthApiService {
  final Dio _dio = DioFactory.getDio();

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

Future<Response?> logout() async {
  await SecureStorage.clear();
}

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    await saveTokens(
      accessToken: response.data['access_token'],
      refreshToken: response.data['refresh_token'],
    );

    return response;
  }
  Future<Response> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String guardianType,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'password': password,
        'guardian_type': guardianType,
      },
    );

    await saveTokens(
      accessToken: response.data['access_token'],
      refreshToken: response.data['refresh_token'],
    );
    
    return response;
  }
}
