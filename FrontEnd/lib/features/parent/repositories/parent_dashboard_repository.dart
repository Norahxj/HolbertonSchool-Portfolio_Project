import '../../../models/child_model.dart';
import '../services/child_api_service.dart';
import '../../../services/user_api_service.dart';
import '../models/parent_dashboard_data.dart';
import '../services/dashboard_api_service.dart';

/// Coordinates all API requests required by the parent dashboard.
///
/// The controller asks for one complete dashboard result instead of
/// knowing that the data comes from several separate services.
class ParentDashboardRepository {
  final UserApiService _userApiService;
  final DashboardApiService _dashboardApiService;
  final ChildApiService _childApiService;

  ParentDashboardRepository({
    UserApiService? userApiService,
    DashboardApiService? dashboardApiService,
    ChildApiService? childApiService,
  })  : _userApiService = userApiService ?? UserApiService(),
        _dashboardApiService =
            dashboardApiService ?? DashboardApiService(),
        _childApiService =
            childApiService ?? ChildApiService();

  Future<ParentDashboardData> getDashboardData() async {
    final userFuture = _userApiService.getCurrentUser();
    final dashboardsFuture =
        _dashboardApiService.getDashboard();

    final user = await userFuture;
    final dashboards = await dashboardsFuture;

    final childItems = dashboards.map((dashboard) {
      final child = ChildModel(
        id: dashboard.childId,
        name: dashboard.childName,
        birthDate: dashboard.birthDate,
        phone: dashboard.phone,
        age: dashboard.childAge,
        accessCode: dashboard.accessCode,
        role: dashboard.role,
        weeklyProgress:
            dashboard.progressPercentage.round(),
        avatarIndex: dashboard.avatarIndex,
      );

      return ParentDashboardChildItem(
        child: child,
        dashboard: dashboard,
        points: dashboard.totalPoints,
      );
    }).toList();

    return ParentDashboardData(
      user: user,
      children: childItems,
    );
  }

  Future<void> deleteChild(String childId) async {
    await _childApiService.deleteChild(childId);
  }
}