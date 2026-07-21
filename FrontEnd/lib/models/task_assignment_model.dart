import 'package:frontend/models/assignment_child_model.dart';

import 'task_model.dart';

class TaskAssignmentModel {
  final String id;
  final String status;
  final DateTime? completedAt;
  final DateTime? approvedAt;
  final TaskModel task;
  final AssignmentChildModel? child;
  final DateTime assignedDate;

  TaskAssignmentModel({
    required this.id,
    required this.status,
    this.completedAt,
    this.approvedAt,
    required this.task,
    this.child,
    required this.assignedDate,
  });

  factory TaskAssignmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TaskAssignmentModel(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      task: TaskModel.fromJson(json['task']),
      child: json['child'] != null
          ? AssignmentChildModel.fromJson(json['child'])
          : null,
      assignedDate: DateTime.parse(
        json['assigned_date'],
      ),
    );
  }
  
  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'status': status,
    'completed_at': completedAt?.toIso8601String(),
    'approved_at': approvedAt?.toIso8601String(),
    'task': task.toJson(),
    'assigned_date': assignedDate.toIso8601String(),
  };
}
}
