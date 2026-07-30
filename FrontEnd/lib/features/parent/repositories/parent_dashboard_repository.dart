import '../../../models/child_dashboard_model.dart';
import '../../../models/child_model.dart';
import '../../../services/user_api_service.dart';
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

  ParentDashboardRepository({
  UserApiService? userApiService,
  ChildApiService? childApiService,
  DashboardApiService? dashboardApiService,
})  : _userApiService = userApiService ?? UserApiService(),
      _childApiService = childApiService ?? ChildApiService(),
      _dashboardApiService =
          dashboardApiService ?? DashboardApiService();


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

    

    final childItems = children.map((child) {
      final dashboard = dashboardByChildId[child.id] ?? _emptyDashboard(child);

      return ParentDashboardChildItem(
        child: child,
        dashboard: dashboard,
       points: dashboard.totalPoints,
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
      totalPoints: 0,
    );
  }
}
