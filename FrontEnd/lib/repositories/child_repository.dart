import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_result.dart';
import 'package:frontend/models/child_model.dart';
import 'package:frontend/services/child_api_service.dart';

class ChildRepository {
  final ChildApiService _childApiService = ChildApiService();

  Future<ApiResult<List<ChildModel>>> getChildren() async {
    try {
      final children = await _childApiService.getChildren();
      return ApiResult.success(children);
    } on DioException catch (e) {
      return ApiResult.failure(
        Map<String, dynamic>.from(e.response?.data ?? {}),
      );
    }
  }

  Future<ApiResult<ChildModel>> getChildById(String childId) async {
    try {
      final child = await _childApiService.getChildById(childId);
      return ApiResult.success(child);
    } on DioException catch (e) {
      return ApiResult.failure(
        Map<String, dynamic>.from(e.response?.data ?? {}),
      );
    }
  }

  Future<ApiResult<ChildModel>> addChild({
    required String name,
    required String birthDate,
    String? phone,
  }) async {
    try {
      final child = await _childApiService.addChild(
        name: name,
        birthDate: birthDate,
        phone: phone,
      );

      return ApiResult.success(child);
    } on DioException catch (e) {
      return ApiResult.failure(
        Map<String, dynamic>.from(e.response?.data ?? {}),
      );
    }
  }
}