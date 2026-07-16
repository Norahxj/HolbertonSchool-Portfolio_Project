import '../core/network/api_service.dart';
import '../core/network/dio_factory.dart';

class PointApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  /// Child: get my own total points balance.
  Future<int> getMyPoints() async {
    final response = await _apiService.getMyPoints();
    final data = response.data as Map<String, dynamic>;
    return (data['total_points'] as num?)?.toInt() ?? 0;
  }

  /// Parent: get a specific child's total points balance.
  Future<int> getChildPoints(String childId) async {
    final response = await _apiService.getChildPoints(childId);
    final data = response.data as Map<String, dynamic>;
    return (data['total_points'] as num?)?.toInt() ?? 0;
  }
}
