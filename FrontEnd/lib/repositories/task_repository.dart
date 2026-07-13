import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_result.dart';
import 'package:frontend/models/create_task_request.dart';
import 'package:frontend/models/task_model.dart';
import 'package:frontend/models/update_task_request.dart';
import 'package:frontend/services/task_api_service.dart';

class TaskRepository {
  final TaskApiService _taskApiService = TaskApiService();

  Future<ApiResult<List<TaskModel>>> getTasks() async {
    try {
      final tasks = await _taskApiService.getTasks();
      return ApiResult.success(tasks);
    } on DioException catch (e) {
      return ApiResult.failure(
        Map<String, dynamic>.from(e.response?.data ?? {}),
      );
    }
  }

  Future<ApiResult<TaskModel>> getTaskById(String taskId) async {
    try {
      final task = await _taskApiService.getTaskById(taskId);
      return ApiResult.success(task);
    } on DioException catch (e) {
      return ApiResult.failure(
        Map<String, dynamic>.from(e.response?.data ?? {}),
      );
    }
  }

  Future<ApiResult<TaskModel>> createTask(
    CreateTaskRequest request,
  ) async {
    try {
      final task = await _taskApiService.createTask(request);
      return ApiResult.success(task);
    } on DioException catch (e) {
      return ApiResult.failure(
        Map<String, dynamic>.from(e.response?.data ?? {}),
      );
    }
  }

  Future<ApiResult<TaskModel>> updateTask(
    String taskId,
    UpdateTaskRequest request,
  ) async {
    try {
      final task = await _taskApiService.updateTask(taskId, request);
      return ApiResult.success(task);
    } on DioException catch (e) {
      return ApiResult.failure(
        Map<String, dynamic>.from(e.response?.data ?? {}),
      );
    }
  }

  Future<ApiResult<List<TaskModel>>> getTasksByChild(
    String childId,
  ) async {
    try {
      final tasks = await _taskApiService.getTasksByChild(childId);
      return ApiResult.success(tasks);
    } on DioException catch (e) {
      return ApiResult.failure(
        Map<String, dynamic>.from(e.response?.data ?? {}),
      );
    }
  }
}