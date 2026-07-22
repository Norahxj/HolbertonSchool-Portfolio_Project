import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/dio_factory.dart';

class PointApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  // Child: get their own points.
  Future<int> getMyPoints() async {
    final response = await _apiService.getMyPoints();

    final data = response.data;

    if (data is Map) {
      return (data['total_points'] as num?)?.toInt() ?? 0;
    }

    return 0;
  }

  // Parent: get the points of one child.
  Future<int> getChildPoints(String childId) async {
    final response = await _apiService.getChildPoints(childId);

    final data = response.data;

    if (data is Map) {
      return (data['total_points'] as num?)?.toInt() ?? 0;
    }

    return 0;
  }
}
