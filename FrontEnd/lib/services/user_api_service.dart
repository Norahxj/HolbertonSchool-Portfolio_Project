import 'package:dio/dio.dart';
import '../core/network/dio_factory.dart';
import '../models/user_model.dart';

class UserApiService {
  final Dio _dio = DioFactory.getDio();

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get('/users/me');
    return UserModel.fromJson(response.data);
  }
}