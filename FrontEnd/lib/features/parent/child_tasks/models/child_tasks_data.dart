import '../../../../models/task_assignment_model.dart';
import 'upcoming_child_task.dart';

class ChildTasksData {
  final List<TaskAssignmentModel> assignments;
  final List<UpcomingChildTask> upcomingTasks;
  final Set<String> deletableTaskIds;

  const ChildTasksData({
    required this.assignments,
    required this.upcomingTasks,
    required this.deletableTaskIds,
  });
}
