import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/dio_factory.dart';
import 'package:frontend/models/child_model.dart';

// Handles parent requests related to children.
class ChildApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  // Gets all children associated with the parent.
  Future<List<ChildModel>> getChildren() async {
    final response = await _apiService.getChildren();

    return response.data;
  }

  // Adds a new child.
  //
  // avatar_index is intentionally not sent because
  // the current backend endpoint does not support it.
  Future<ChildModel> addChild({
    required String name,
    required String birthDate,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'birth_date': birthDate,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };

    final response = await _apiService.addChild(body);

    return response.data;
  }

  // Gets information about one child.
  Future<ChildModel> getChildById(String childId) async {
    final response = await _apiService.getChild(childId);

    return response.data;
  }

  // Deletes a child and their related data.
  Future<void> deleteChild(String childId) async {
    await _apiService.deleteChild(childId);
  }
}
