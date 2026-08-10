import '../../../../models/child_model.dart';
import '../../../../models/daily_feedback_model.dart';
import '../../../../models/task_assignment_model.dart';

class ChildHomeData {
  final ChildModel child;
  final List<TaskAssignmentModel> assignments;
  final DailyFeedbackModel? todayFeedback;
  final int points;

  const ChildHomeData({
    required this.child,
    required this.assignments,
    required this.todayFeedback,
    required this.points,
  });
}