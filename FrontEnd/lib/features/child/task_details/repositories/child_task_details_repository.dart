import '../../../../services/task_api_service.dart';

class ChildTaskDetailsRepository {
  final TaskApiService _taskApiService;

  ChildTaskDetailsRepository({
    TaskApiService? taskApiService,
  }) : _taskApiService = taskApiService ?? TaskApiService();

  Future<void> completeAssignment(String assignmentId) async {
    await _taskApiService.completeAssignment(assignmentId);
  }
}