import 'package:dio/dio.dart';
import '../core/network/api_constants.dart';
import '../core/network/dio_factory.dart';

class AuthApiService {
  final Dio _dio = DioFactory.getDio();

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String guardianType,
  }) async {
    return await _dio.post(
      ApiConstants.register,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'password': password,
        'guardian_type': guardianType,
      },
    );
  }
}
