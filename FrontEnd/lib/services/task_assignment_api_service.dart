import '../core/network/api_service.dart';
import '../core/network/dio_factory.dart';
import '../models/task_assignment_model.dart';

class TaskAssignmentApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  Future<List<TaskAssignmentModel>> getMyAssignments() async {
    final response = await _apiService.getMyAssignments();
    return response.data;
  }
}