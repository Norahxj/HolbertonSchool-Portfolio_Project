/// Represents one task assigned to a child.
///
/// Supported statuses:
/// - PENDING: The child has not completed the task.
/// - COMPLETED: Legacy status for a completed task.
/// - PENDING_REVIEW: The child completed the task and needs parent approval.
/// - APPROVED: The task was approved.
/// - REJECTED: The task was rejected.
class TaskAssignmentModel {
  final String id;
  final String status;
  final DateTime? completedAt;
  final DateTime? approvedAt;
  final AssignmentTask task;
  final DateTime assignedDate;

  const TaskAssignmentModel({
    required this.id,
    required this.status,
    this.completedAt,
    this.approvedAt,
    required this.task,
    required this.assignedDate,
  });

  factory TaskAssignmentModel.fromJson(Map<String, dynamic> json) {
    return TaskAssignmentModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      completedAt: _parseDateTime(json['completed_at']),
      approvedAt: _parseDateTime(json['approved_at']),
      task: AssignmentTask.fromJson(
        json['task'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      assignedDate: _parseDateTime(json['assigned_date']) ?? DateTime.now(),
    );
  }

  String get normalizedStatus {
    return status.toUpperCase();
  }

  bool get isPending {
    return normalizedStatus == 'PENDING';
  }

  bool get isApproved {
    return normalizedStatus == 'APPROVED';
  }

  bool get isRejected {
    return normalizedStatus == 'REJECTED';
  }

  /// Supports both the current and older backend status names.
  bool get isPendingReview {
    return normalizedStatus == 'PENDING_REVIEW' ||
        normalizedStatus == 'COMPLETED';
  }

  /// The child completed the task and the parent must approve it.
  bool get needsParentApproval {
    if (normalizedStatus == 'PENDING_REVIEW') {
      return true;
    }

    if (normalizedStatus == 'COMPLETED') {
      return !task.isAutoVerified;
    }

    return false;
  }

  /// A completed task contributes to progress even while waiting
  /// for the parent to review it.
  bool get countsTowardProgress {
    return isApproved || isPendingReview;
  }
}

/// Task details returned inside an assignment.
class AssignmentTask {
  final String id;
  final String title;
  final String description;
  final int points;
  final String taskFrequency;
  final int? recurrenceDay;
  final String? category;
  final bool isAutoVerified;

  const AssignmentTask({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.taskFrequency,
    this.recurrenceDay,
    this.category,
    required this.isAutoVerified,
  });

  factory AssignmentTask.fromJson(Map<String, dynamic> json) {
    return AssignmentTask(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      taskFrequency: json['task_frequency']?.toString() ?? '',
      recurrenceDay: (json['recurrence_day'] as num?)?.toInt(),
      category: json['category']?.toString(),
      isAutoVerified: _parseBool(json['is_auto_verified']),
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}

bool _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  final text = value?.toString().toLowerCase();

  return text == 'true' || text == '1' || text == 'yes';
}
