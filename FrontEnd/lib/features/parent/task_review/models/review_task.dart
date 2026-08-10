import '../../../../models/child_model.dart';
import '../../../../models/task_assignment_model.dart';

class ReviewTask {
  final ChildModel child;
  final TaskAssignmentModel assignment;

  const ReviewTask({required this.child, required this.assignment});
}
