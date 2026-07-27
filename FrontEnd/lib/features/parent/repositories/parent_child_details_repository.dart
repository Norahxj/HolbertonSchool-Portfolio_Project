import '../../../models/task_assignment_model.dart';
import '../../../services/task_api_service.dart';

/// Handles the task data required by the parent's child-details screen.
class ParentChildDetailsRepository {
  final TaskApiService _taskApiService;

  ParentChildDetailsRepository({TaskApiService? taskApiService})
    : _taskApiService = taskApiService ?? TaskApiService();

  Future<List<TaskAssignmentModel>> getChildTasks(String childId) async {
    final assignments = [
      ...await _taskApiService.getAssignmentsForChild(childId),
    ];

    // Display the newest assignments first.
    assignments.sort((first, second) {
      return second.assignedDate.compareTo(first.assignedDate);
    });

    return assignments;
  }
}
