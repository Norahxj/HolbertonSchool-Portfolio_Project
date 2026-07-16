import 'task_model.dart';

class TaskAssignmentModel {
  final String id;
  final String status;
  final DateTime? completedAt;
  final DateTime? approvedAt;
  final DateTime assignedDate;
  final TaskModel task;

  TaskAssignmentModel({
    required this.id,
    required this.status,
    this.completedAt,
    this.approvedAt,
    required this.assignedDate,
    required this.task,
  });

  factory TaskAssignmentModel.fromJson(Map<String, dynamic> json) {
    return TaskAssignmentModel(
      id: json['id'],
      status: json['status'],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      assignedDate: DateTime.parse(json['assigned_date']),
      task: TaskModel.fromJson(json['task']),
    );
  }
}