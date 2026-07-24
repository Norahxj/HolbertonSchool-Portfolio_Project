import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/dio_factory.dart';
import 'package:frontend/models/child_model.dart';

// Handles parent requests related to children.
class ChildApiService {
  final ApiService _apiService =
      ApiService(DioFactory.getDio());

  // Gets all children.
  Future<List<ChildModel>> getChildren() async {
    final response = await _apiService.getChildren();

    return response.data;
  }

  // Adds a new child.
  Future<ChildModel> addChild({
    required String name,
    required String birthDate,
    required int avatarIndex,
    String? phone,
  }) async {
    final body = {
      'name': name,
      'birth_date': birthDate,
      'avatar_index': avatarIndex,
      if (phone != null && phone.isNotEmpty)
        'phone': phone,
    };

    final response = await _apiService.addChild(body);

    return response.data;
  }

  // Gets information about one child.
  Future<ChildModel> getChildById(
    String childId,
  ) async {
    final response =
        await _apiService.getChild(childId);

    return response.data;
  }
}