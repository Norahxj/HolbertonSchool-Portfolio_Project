import 'package:dio/dio.dart';

import '../core/network/dio_factory.dart';
import '../models/user_model.dart';

class UserApiService {
  final Dio _dio = DioFactory.getDio();

  // Get the signed-in parent's information.
  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get('/users/me');

    return UserModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  // Update the signed-in parent's information.
  Future<UserModel> updateCurrentUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    final response = await _dio.put(
      '/users/me',
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
      },
    );

    return UserModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}
