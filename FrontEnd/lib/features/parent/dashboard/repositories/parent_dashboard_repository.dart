import '../../../../models/child_model.dart';
import '../../../../services/user_api_service.dart';
import '../../services/dashboard_api_service.dart';
import '../models/parent_dashboard_data.dart';

class ParentDashboardRepository {
  final UserApiService _userApiService;
  final DashboardApiService _dashboardApiService;

  ParentDashboardRepository({
    UserApiService? userApiService,
    DashboardApiService? dashboardApiService,
  }) : _userApiService = userApiService ?? UserApiService(),
       _dashboardApiService = dashboardApiService ?? DashboardApiService();

  Future<ParentDashboardData> getDashboardData() async {
    final userFuture = _userApiService.getCurrentUser();

    final dashboardsFuture = _dashboardApiService.getDashboard();

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
        weeklyProgress: dashboard.progressPercentage.round(),
        avatarIndex: dashboard.avatarIndex,
      );

      return ParentDashboardChildItem(
        child: child,
        dashboard: dashboard,
        points: dashboard.totalPoints,
      );
    }).toList();

    return ParentDashboardData(user: user, children: childItems);
  }
}
