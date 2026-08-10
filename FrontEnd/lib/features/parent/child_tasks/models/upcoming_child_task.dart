import '../../../../models/task_model.dart';

class UpcomingChildTask {
  final TaskModel task;
  final DateTime nextDate;

  const UpcomingChildTask({required this.task, required this.nextDate});
}
