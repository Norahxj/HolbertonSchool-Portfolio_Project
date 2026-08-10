import '../../../../models/child_progress_summary_model.dart';
import '../../../../models/task_assignment_model.dart';
import '../../../../services/task_api_service.dart';
import '../../services/point_api_service.dart';
import '../models/child_progress_data.dart';

class ChildProgressRepository {
  final TaskApiService _taskApiService;
  final PointApiService _pointApiService;

  ChildProgressRepository({
    TaskApiService? taskApiService,
    PointApiService? pointApiService,
  }) : _taskApiService =
            taskApiService ?? TaskApiService(),
       _pointApiService =
            pointApiService ?? PointApiService();

  Future<ChildProgressData> getProgressData() async {
    final results = await Future.wait([
      _taskApiService.getMyCurrentWeekAssignments(),
      _pointApiService.getMyPoints(),
      _taskApiService.getMyProgressSummary(),
    ]);

    return ChildProgressData(
      assignments:
          results[0] as List<TaskAssignmentModel>,
      points: results[1] as int,
      summary:
          results[2] as ChildProgressSummaryModel,
    );
  }
}