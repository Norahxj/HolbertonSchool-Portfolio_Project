class PointsHistoryModel {
  final String id;
  final String childId;
  final int points;
  final String action;
  final DateTime createdAt;
  final PointsHistoryTaskAssignment? taskAssignment;
  final PointsHistoryWishlist? wishlist;

  const PointsHistoryModel({
    required this.id,
    required this.childId,
    required this.points,
    required this.action,
    required this.createdAt,
    this.taskAssignment,
    this.wishlist,
  });

  factory PointsHistoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PointsHistoryModel(
      id: json['id']?.toString() ?? '',
      childId: json['child_id']?.toString() ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      action: json['action']?.toString() ?? '',
      createdAt: DateTime.parse(
        json['created_at'].toString(),
      ),
      taskAssignment: json['task_assignment'] == null
          ? null
          : PointsHistoryTaskAssignment.fromJson(
              json['task_assignment']
                  as Map<String, dynamic>,
            ),
      wishlist: json['wishlist'] == null
          ? null
          : PointsHistoryWishlist.fromJson(
              json['wishlist']
                  as Map<String, dynamic>,
            ),
    );
  }
}

class PointsHistoryTaskAssignment {
  final String id;
  final String status;
  final DateTime? assignedDate;
  final DateTime? completedAt;
  final DateTime? approvedAt;
  final PointsHistoryTask task;

  const PointsHistoryTaskAssignment({
    required this.id,
    required this.status,
    required this.task,
    this.assignedDate,
    this.completedAt,
    this.approvedAt,
  });

  factory PointsHistoryTaskAssignment.fromJson(
    Map<String, dynamic> json,
  ) {
    return PointsHistoryTaskAssignment(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      assignedDate: json['assigned_date'] == null
          ? null
          : DateTime.tryParse(
              json['assigned_date'].toString(),
            ),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.tryParse(
              json['completed_at'].toString(),
            ),
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.tryParse(
              json['approved_at'].toString(),
            ),
      task: PointsHistoryTask.fromJson(
        json['task'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class PointsHistoryTask {
  final String id;
  final String title;
  final String description;
  final int points;
  final String category;

  const PointsHistoryTask({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.category,
  });

  factory PointsHistoryTask.fromJson(
    Map<String, dynamic> json,
  ) {
    return PointsHistoryTask(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      category: json['category']?.toString() ?? '',
    );
  }
}

class PointsHistoryWishlist {
  final String id;
  final String name;
  final int? targetPoints;
  final String status;
  final DateTime? approvedAt;

  const PointsHistoryWishlist({
    required this.id,
    required this.name,
    required this.status,
    this.targetPoints,
    this.approvedAt,
  });

  factory PointsHistoryWishlist.fromJson(
    Map<String, dynamic> json,
  ) {
    return PointsHistoryWishlist(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      targetPoints:
          (json['target_points'] as num?)?.toInt(),
      status: json['status']?.toString() ?? '',
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.tryParse(
              json['approved_at'].toString(),
            ),
    );
  }
}