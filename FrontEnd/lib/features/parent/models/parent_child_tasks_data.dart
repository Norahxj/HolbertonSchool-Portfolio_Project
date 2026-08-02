import '../../../models/task_assignment_model.dart';
import '../../../models/task_model.dart';

/// A recurring task that has not generated its next assignment yet.
class UpcomingTaskItem {
  final TaskModel task;
  final DateTime nextDate;

  const UpcomingTaskItem({required this.task, required this.nextDate});
}

/// All task information needed by the parent's child-tasks screens.
class ParentChildTasksData {
  final List<TaskAssignmentModel> assignments;
  final List<UpcomingTaskItem> upcomingTasks;

  const ParentChildTasksData({
    required this.assignments,
    required this.upcomingTasks,
  });
}
