import '../../../../models/task_assignment_model.dart';
import '../../../../services/task_api_service.dart';

class TaskReviewRepository {
  final TaskApiService _taskApiService;

  TaskReviewRepository({
    TaskApiService? taskApiService,
  }) : _taskApiService = taskApiService ?? TaskApiService();

  Future<List<TaskAssignmentModel>> getPendingReviewAssignments() {
    return _taskApiService.getPendingReviewAssignments();
  }

  Future<void> approveAssignment(String assignmentId) {
    return _taskApiService.approveAssignment(assignmentId);
  }

  Future<void> rejectAssignment(String assignmentId) {
    return _taskApiService.rejectAssignment(assignmentId);
  }
}