import '../../../../models/child_dashboard_model.dart';
import '../../../../models/child_model.dart';
import '../../../../models/user_model.dart';

class ParentDashboardChildItem {
  final ChildModel child;
  final ChildDashboardModel dashboard;
  final int? points;

  const ParentDashboardChildItem({
    required this.child,
    required this.dashboard,
    required this.points,
  });
}

class ParentDashboardData {
  final UserModel user;
  final List<ParentDashboardChildItem> children;

  const ParentDashboardData({required this.user, required this.children});

  int get childrenCount => children.length;

  int get pendingReviewCount {
    return children.fold(0, (total, item) {
      return total + item.dashboard.pendingReviewTasks;
    });
  }

  int get totalTasks {
    return children.fold(0, (total, item) {
      return total + item.dashboard.totalTasks;
    });
  }

  int get completedTasks {
    return children.fold(0, (total, item) {
      return total + item.dashboard.completedTasks;
    });
  }
}
