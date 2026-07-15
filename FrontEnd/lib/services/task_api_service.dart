import '../core/network/api_service.dart';
import '../core/network/dio_factory.dart';
import '../models/task_model.dart';
import '../models/task_suggestion_model.dart';
import '../models/task_suggestions_response.dart';

class TaskApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  Future<TaskModel> createTask(Map<String, dynamic> body) async {
    final response = await _apiService.createTask(body);
    return response.data;
  }

  Future<List<TaskModel>> getTasks() async {
    final response = await _apiService.getTasks();
    return response.data;
  }

  Future<TaskModel> getTaskById(String taskId) async {
    final response = await _apiService.getTask(taskId);
    return response.data;
  }

  Future<TaskModel> updateTask(
    String taskId,
    Map<String, dynamic> body,
  ) async {
    final response = await _apiService.updateTask(taskId, body);
    return response.data;
  }

  Future<List<TaskModel>> getTasksByChild(String childId) async {
    final response = await _apiService.getTasksByChild(childId);
    return response.data;
  }
  Future<List<TaskSuggestionModel>> getTaskSuggestions(
  Map<String, dynamic> body,
) async {
  final response = await _apiService.getTaskSuggestions(body);
  return response.data.suggestions;
}
}