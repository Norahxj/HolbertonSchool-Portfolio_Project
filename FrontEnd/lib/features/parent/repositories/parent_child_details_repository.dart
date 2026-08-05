import '../../../models/task_assignment_model.dart';
import '../../../models/task_model.dart';
import '../../../services/task_api_service.dart';
import '../models/parent_child_tasks_data.dart';

/// Handles the task data required by the parent's child-details screens.
class ParentChildDetailsRepository {
  final TaskApiService _taskApiService;

  ParentChildDetailsRepository({TaskApiService? taskApiService})
    : _taskApiService = taskApiService ?? TaskApiService();

  /// Loads both:
  /// 1. Existing task assignments.
  /// 2. Weekly and monthly tasks whose next assignment is still in the future.
  Future<ParentChildTasksData> getChildTasksData(String childId) async {
    final results = await Future.wait([
      _taskApiService.getAssignmentsForChild(childId),

      // جميع المهام المرتبطة بالطفل، سواء أنشأها الأب أو الأم.
      _taskApiService.getTasksByChild(childId),

      // المهام التي أنشأها المستخدم المسجل حاليًا فقط.
      _taskApiService.getTasks(),
    ]);

    final assignments = List<TaskAssignmentModel>.from(results[0]);

    final taskDefinitions = List<TaskModel>.from(results[1]);

    final currentParentTasks = List<TaskModel>.from(results[2]);

    final deletableTaskIds = currentParentTasks.map((task) => task.id).toSet();

    // Display the newest generated assignments first.
    assignments.sort((first, second) {
      return second.assignedDate.compareTo(first.assignedDate);
    });

    final today = _riyadhToday();
    final upcomingTasks = <UpcomingTaskItem>[];

    for (final task in taskDefinitions) {
      final nextDate = _nextOccurrence(task: task, today: today);

      if (nextDate == null) {
        continue;
      }

      final hasAssignmentForNextDate = assignments.any((assignment) {
        return assignment.task.id == task.id &&
            _isSameDate(assignment.assignedDate, nextDate);
      });

      // Future recurring tasks belong in Upcoming.
      //
      // A task due today is also shown when the daily backend job has not
      // generated its assignment yet. Once the assignment exists, this check
      // prevents the task from appearing twice.
      if (nextDate.isAfter(today) || !hasAssignmentForNextDate) {
        upcomingTasks.add(UpcomingTaskItem(task: task, nextDate: nextDate));
      }
    }

    // Show the nearest upcoming task first.
    upcomingTasks.sort((first, second) {
      return first.nextDate.compareTo(second.nextDate);
    });

    return ParentChildTasksData(
      assignments: assignments,
      upcomingTasks: upcomingTasks,
      deletableTaskIds: deletableTaskIds,
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _taskApiService.deleteTask(taskId);
  }

  DateTime _riyadhToday() {
    final riyadhNow = DateTime.now().toUtc().add(const Duration(hours: 3));

    return DateTime(riyadhNow.year, riyadhNow.month, riyadhNow.day);
  }

  DateTime? _nextOccurrence({
    required TaskModel task,
    required DateTime today,
  }) {
    final frequency = task.taskFrequency.toUpperCase();
    final recurrenceDay = task.recurrenceDay;

    if (recurrenceDay == null) {
      return null;
    }

    if (frequency == 'WEEKLY') {
      return _nextWeeklyDate(recurrenceDay: recurrenceDay, today: today);
    }

    if (frequency == 'MONTHLY') {
      return _nextMonthlyDate(recurrenceDay: recurrenceDay, today: today);
    }

    return null;
  }

  DateTime? _nextWeeklyDate({
    required int recurrenceDay,
    required DateTime today,
  }) {
    // The backend uses:
    // 0 = Monday, 1 = Tuesday, ... 6 = Sunday.
    if (recurrenceDay < 0 || recurrenceDay > 6) {
      return null;
    }

    final targetWeekday = recurrenceDay + 1;

    final daysUntilTarget = (targetWeekday - today.weekday + 7) % 7;

    return today.add(Duration(days: daysUntilTarget));
  }

  DateTime? _nextMonthlyDate({
    required int recurrenceDay,
    required DateTime today,
  }) {
    if (recurrenceDay < 1 || recurrenceDay > 31) {
      return null;
    }

    // Match the backend rule:
    // if the selected day does not exist in a month, use that month's
    // final day. For example, day 31 becomes February 28 or 29.
    for (int monthOffset = 0; monthOffset < 24; monthOffset++) {
      final monthIndex = today.month - 1 + monthOffset;

      final year = today.year + monthIndex ~/ 12;

      final month = monthIndex % 12 + 1;

      final daysInMonth = DateTime(year, month + 1, 0).day;

      final effectiveDay = recurrenceDay > daysInMonth
          ? daysInMonth
          : recurrenceDay;

      final candidate = DateTime(year, month, effectiveDay);

      if (!candidate.isBefore(today)) {
        return candidate;
      }
    }

    return null;
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
