class ChildDashboardModel {
  final String childId;
  final String childName;
  final int childAge;
  final String weekStart;
  final String weekEnd;
  final double progressPercentage;
  final int completedTasks;
  final int approvedTasks;
  final int pendingReviewTasks;
  final int pendingTasks;
  final int rejectedTasks;
  final int remainingTasks;
  final int totalTasks;

  const ChildDashboardModel({
    required this.childId,
    required this.childName,
    required this.childAge,
    required this.weekStart,
    required this.weekEnd,
    required this.progressPercentage,
    required this.completedTasks,
    required this.approvedTasks,
    required this.pendingReviewTasks,
    required this.pendingTasks,
    required this.rejectedTasks,
    required this.remainingTasks,
    required this.totalTasks,
  });

  factory ChildDashboardModel.fromJson(Map<String, dynamic> json) {
    return ChildDashboardModel(
      childId: json['child_id']?.toString() ?? '',
      childName: json['child_name']?.toString() ?? '',
      childAge: (json['child_age'] as num?)?.toInt() ?? 0,
      weekStart: json['week_start']?.toString() ?? '',
      weekEnd: json['week_end']?.toString() ?? '',
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0,
      completedTasks:
          (json['completed_tasks'] as num?)?.toInt() ?? 0,
      approvedTasks:
          (json['approved_tasks'] as num?)?.toInt() ?? 0,
      pendingReviewTasks:
          (json['pending_review_tasks'] as num?)?.toInt() ?? 0,
      pendingTasks:
          (json['pending_tasks'] as num?)?.toInt() ?? 0,
      rejectedTasks:
          (json['rejected_tasks'] as num?)?.toInt() ?? 0,
      remainingTasks:
          (json['remaining_tasks'] as num?)?.toInt() ?? 0,
      totalTasks:
          (json['total_tasks'] as num?)?.toInt() ?? 0,
    );
  }
}