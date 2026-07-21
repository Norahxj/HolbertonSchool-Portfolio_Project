import '../core/network/api_service.dart';
import '../core/network/dio_factory.dart';
import '../models/child_dashboard_model.dart';

class DashboardApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  Future<List<ChildDashboardModel>> getDashboard() async {
    final response = await _apiService.getDashboard();
    return response.data;
  }
}