import '../core/network/api_service.dart';
import '../core/network/dio_factory.dart';
import '../models/create_task_request.dart';
import '../models/task_model.dart';
import '../models/update_task_request.dart';

class TaskApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  Future<TaskModel> createTask(CreateTaskRequest request) async {
    final response = await _apiService.createTask(request);
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
    UpdateTaskRequest request,
  ) async {
    final response = await _apiService.updateTask(taskId, request);
    return response.data;
  }


  Future<List<TaskModel>> getTasksByChild(String childId) async {
    final response = await _apiService.getTasksByChild(childId);
    return response.data;
  }
}