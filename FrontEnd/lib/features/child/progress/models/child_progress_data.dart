import '../../../../models/child_progress_summary_model.dart';
import '../../../../models/task_assignment_model.dart';

class ChildProgressData {
  final List<TaskAssignmentModel> assignments;
  final ChildProgressSummaryModel summary;
  final int points;

  const ChildProgressData({
    required this.assignments,
    required this.summary,
    required this.points,
  });
}