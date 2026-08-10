import '../../../../core/storage/secure_storage.dart';
import '../../../../models/child_model.dart';
import '../../../../models/daily_feedback_model.dart';
import '../../../../models/task_assignment_model.dart';
import '../../../../services/daily_feedback_api_service.dart';
import '../../../../services/task_api_service.dart';
import '../../services/point_api_service.dart';
import '../models/child_home_data.dart';

class ChildHomeRepository {
  final DailyFeedbackApiService _feedbackApiService;
  final TaskApiService _taskApiService;
  final PointApiService _pointApiService;

  ChildHomeRepository({
    DailyFeedbackApiService? feedbackApiService,
    TaskApiService? taskApiService,
    PointApiService? pointApiService,
  })  : _feedbackApiService =
            feedbackApiService ?? DailyFeedbackApiService(),
        _taskApiService = taskApiService ?? TaskApiService(),
        _pointApiService = pointApiService ?? PointApiService();

  Future<ChildHomeData?> getHomeData() async {
    final childFuture = SecureStorage.getChild();

    final assignmentsFuture =
        _taskApiService.getMyCurrentWeekAssignments();

    final pointsFuture = _pointApiService.getMyPoints();

    final feedbackFuture = _getTodayFeedbackSafely();

    final results = await Future.wait([
      childFuture,
      assignmentsFuture,
      pointsFuture,
      feedbackFuture,
    ]);

    final child = results[0] as ChildModel?;

    if (child == null) {
      return null;
    }

    return ChildHomeData(
      child: child,
      assignments: results[1] as List<TaskAssignmentModel>,
      points: results[2] as int,
      todayFeedback: results[3] as DailyFeedbackModel?,
    );
  }

  Future<void> completeAssignment(String assignmentId) async {
    await _taskApiService.completeAssignment(assignmentId);
  }

  Future<List<TaskAssignmentModel>> getAssignments() async {
    return _taskApiService.getMyCurrentWeekAssignments();
  }

  Future<int> getPoints() async {
    return _pointApiService.getMyPoints();
  }

  Future<DailyFeedbackModel?> _getTodayFeedbackSafely() async {
    try {
      return await _feedbackApiService.getMyTodayFeedback();
    } catch (_) {
      return null;
    }
  }
}