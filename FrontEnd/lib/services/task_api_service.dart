import '../core/network/api_service.dart';
import '../core/network/dio_factory.dart';
import '../models/task_assignment_model.dart';
import '../models/task_model.dart';
import '../models/task_suggestion_model.dart';
import '../models/child_progress_summary_model.dart';

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

  Future<TaskModel> updateTask(String taskId, Map<String, dynamic> body) async {
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

  Future<ChildProgressSummaryModel> getMyProgressSummary() async {
    final response = await _apiService.getMyProgressSummary();

    return ChildProgressSummaryModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<TaskAssignmentModel>> getMyAssignments() async {
    final response = await _apiService.getMyAssignments();

    return _convertAssignments(response.data);
  }

  Future<List<TaskAssignmentModel>> getMyCurrentWeekAssignments() async {
    final response = await _apiService.getMyCurrentWeekAssignments();

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) => TaskAssignmentModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<TaskAssignmentModel>> getAssignmentsForTask(String taskId) async {
    final response = await _apiService.getAssignmentsForTask(taskId);

    return _convertAssignments(response.data);
  }

  Future<List<TaskAssignmentModel>> getAssignmentsForChild(
    String childId,
  ) async {
    final response = await _apiService.getAssignmentsForChild(childId);

    return _convertAssignments(response.data);
  }

  Future<List<TaskAssignmentModel>>
getPendingReviewAssignments() async {
  final response =
      await _apiService.getPendingReviewAssignments();

  return _convertAssignments(response.data);
}



  Future<void> completeAssignment(String assignmentId) async {
    await _apiService.completeAssignment(assignmentId);
  }

  Future<void> approveAssignment(String assignmentId) async {
    await _apiService.approveAssignment(assignmentId);
  }

  Future<void> rejectAssignment(String assignmentId) async {
    await _apiService.rejectAssignment(assignmentId);
  }

  List<TaskAssignmentModel> _convertAssignments(dynamic responseData) {
    if (responseData is List<TaskAssignmentModel>) {
      return responseData;
    }

    if (responseData is List) {
      return responseData.map((item) {
        if (item is TaskAssignmentModel) {
          return item;
        }

        return TaskAssignmentModel.fromJson(item as Map<String, dynamic>);
      }).toList();
    }

    return [];
  }
}
