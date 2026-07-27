class TaskModel {
  final String id;
  final String title;
  final String description;
  final int points;
  final String taskFrequency;
  final int? recurrenceDay;
  final String? category;
  final bool isAutoVerified;
  final String? createdBy;
  final DateTime? createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.taskFrequency,
    this.recurrenceDay,
    this.category,
    required this.isAutoVerified,
    this.createdBy,
    this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      points: json['points'],
      taskFrequency: json['task_frequency'],
      recurrenceDay: json['recurrence_day'],
      category: json['category'],
      isAutoVerified: json['is_auto_verified'],
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'task_frequency': taskFrequency,
      'recurrence_day': recurrenceDay,
      'category': category,
      'is_auto_verified': isAutoVerified,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}