import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/dio_factory.dart';
import 'package:frontend/models/task_assignment_model.dart';
import 'package:frontend/services/task_api_service.dart';

class TaskAssignmentApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());
  final TaskApiService _taskApiService = TaskApiService();

  /// Child get all assignments for the current child
  Future<List<TaskAssignmentModel>> getMyAssignments() async {
    final response = await _apiService.getMyAssignments();
    return response.data;
  }

  /// Parent get all assignments for a specific child
  Future<List<TaskAssignmentModel>> getChildAssignments(
    String childId,
  ) async {
    final response =
        await _apiService.getChildAssignments(childId);
    return response.data;
  }

  /// Child complete assignment
  Future<TaskAssignmentModel> completeAssignment(
    String assignmentId,
  ) async {
    final response =
        await _apiService.completeAssignment(assignmentId);
    return response.data;
  }

  /// Parent approve assignment
  Future<TaskAssignmentModel> approveAssignment(
    String assignmentId,
  ) async {
    final response =
        await _apiService.approveAssignment(assignmentId);
    return response.data;
  }

  /// Parent reject assignment
  Future<TaskAssignmentModel> rejectAssignment(
    String assignmentId,
  ) async {
    final response =
        await _apiService.rejectAssignment(assignmentId);
    return response.data;
  }

  /// Parent get assignments for a specific task
  Future<List<TaskAssignmentModel>> getAssignmentsByTask(
    String taskId,
  ) async {
    final response =
        await _apiService.getAssignmentsByTask(taskId);
    return response.data;
  }

  /// Count assignments waiting for parent review
  Future<int> getPendingReviewCount() async {
    final tasks = await _taskApiService.getTasks();

    int count = 0;

    for (final task in tasks) {
      final assignments = await getAssignmentsByTask(task.id);

      count += assignments
          .where((assignment) =>
              assignment.status == 'PENDING_REVIEW')
          .length;
    }

    return count;
  }
}