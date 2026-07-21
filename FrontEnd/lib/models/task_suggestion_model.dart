class TaskSuggestionModel {
  final String title;
  final String description;
  final int points;
  final String category;
  final String taskFrequency;
  final int? recurrenceDay;
  final bool isAutoVerified;

  TaskSuggestionModel({
    required this.title,
    required this.description,
    required this.points,
    required this.category,
    required this.taskFrequency,
    this.recurrenceDay,
    required this.isAutoVerified,
  });

  factory TaskSuggestionModel.fromJson(Map<String, dynamic> json) {
    return TaskSuggestionModel(
      title: json['title'],
      description: json['description'],
      points: json['points'],
      category: json['category'],
      taskFrequency: json['task_frequency'],
      recurrenceDay: json['recurrence_day'],
      isAutoVerified: json['is_auto_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'points': points,
      'category': category,
      'task_frequency': taskFrequency,
      'recurrence_day': recurrenceDay,
      'is_auto_verified': isAutoVerified,
    };
  }
}