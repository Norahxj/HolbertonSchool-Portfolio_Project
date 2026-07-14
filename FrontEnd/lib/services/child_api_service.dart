import '../core/network/api_service.dart';
import '../core/network/dio_factory.dart';
import '../models/child_model.dart';

class ChildApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  Future<List<ChildModel>> getChildren() async {
    final response = await _apiService.getChildren();
    return response.data;
  }

  Future<ChildModel> addChild({
    required String name,
    required String birthDate,
    String? phone,
  }) async {
    final body = {
      'name': name,
      'birth_date': birthDate,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };

    final response = await _apiService.addChild(body);
    return response.data;
  }

  Future<ChildModel> getChildById(String childId) async {
    final response = await _apiService.getChild(childId);
    return response.data;
  }
}