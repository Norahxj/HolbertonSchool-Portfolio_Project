/// Model for a child's task assignment, matching the backend
/// ChildTaskAssignmentResponseSchema.
class TaskAssignmentModel {
  final String id;
  final String status; // 'pending' | 'completed' | 'approved' | 'rejected'
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
      id: json['id'] as String,
      status: json['status'] as String,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      task: AssignmentTask.fromJson(json['task'] as Map<String, dynamic>),
      assignedDate: DateTime.parse(json['assigned_date'] as String),
    );
  }
}

/// Nested task data returned inside a task assignment.
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
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      points: (json['points'] as num).toInt(),
      taskFrequency: json['task_frequency'] as String? ?? '',
      recurrenceDay: json['recurrence_day'] as int?,
      category: json['category'] as String?,
      isAutoVerified: json['is_auto_verified'] as bool? ?? false,
    );
  }
}