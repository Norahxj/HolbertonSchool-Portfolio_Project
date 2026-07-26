import '../../../models/child_dashboard_model.dart';
import '../../../models/child_model.dart';
import '../../../services/user_api_service.dart';
import '../../child/services/point_api_service.dart';
import '../models/parent_dashboard_data.dart';
import '../services/child_api_service.dart';
import '../services/dashboard_api_service.dart';

/// Coordinates all API requests required by the parent dashboard.
///
/// The controller asks for one complete dashboard result instead of
/// knowing that the data comes from several separate services.
class ParentDashboardRepository {
  final UserApiService _userApiService;
  final ChildApiService _childApiService;
  final DashboardApiService _dashboardApiService;
  final PointApiService _pointApiService;

  ParentDashboardRepository({
    UserApiService? userApiService,
    ChildApiService? childApiService,
    DashboardApiService? dashboardApiService,
    PointApiService? pointApiService,
  }) : _userApiService = userApiService ?? UserApiService(),
       _childApiService = childApiService ?? ChildApiService(),
       _dashboardApiService = dashboardApiService ?? DashboardApiService(),
       _pointApiService = pointApiService ?? PointApiService();

  Future<ParentDashboardData> getDashboardData() async {
    // Starting these futures before awaiting allows the requests
    // to run at the same time.
    final userFuture = _userApiService.getCurrentUser();

    final childrenFuture = _childApiService.getChildren();

    final dashboardsFuture = _dashboardApiService.getDashboard();

    final user = await userFuture;
    final children = await childrenFuture;
    final dashboards = await dashboardsFuture;

    final dashboardByChildId = {
      for (final dashboard in dashboards) dashboard.childId: dashboard,
    };

    final pointsEntries = await Future.wait(
      children.map((child) async {
        try {
          final points = await _pointApiService.getChildPoints(child.id);

          return MapEntry<String, int?>(child.id, points);
        } catch (_) {
          // A failed points request should not prevent the entire
          // dashboard from loading.
          return MapEntry<String, int?>(child.id, null);
        }
      }),
    );

    final pointsByChildId = Map<String, int?>.fromEntries(pointsEntries);

    final childItems = children.map((child) {
      final dashboard = dashboardByChildId[child.id] ?? _emptyDashboard(child);

      return ParentDashboardChildItem(
        child: child,
        dashboard: dashboard,
        points: pointsByChildId[child.id],
      );
    }).toList();

    return ParentDashboardData(user: user, children: childItems);
  }

  Future<void> deleteChild(String childId) async {
    await _childApiService.deleteChild(childId);
  }

  ChildDashboardModel _emptyDashboard(ChildModel child) {
    return ChildDashboardModel(
      childId: child.id,
      childName: child.name,
      childAge: child.age,
      weekStart: '',
      weekEnd: '',
      progressPercentage: 0,
      completedTasks: 0,
      approvedTasks: 0,
      pendingReviewTasks: 0,
      pendingTasks: 0,
      rejectedTasks: 0,
      remainingTasks: 0,
      totalTasks: 0,
    );
  }
}
