class TaskDraft {
  final List<String> childIds;
  final String title;
  final String description;
  final int points;
  final String frequency;
  final int? recurrenceDay;
  final String category;
  final bool isAutoVerified;

  const TaskDraft({
    required this.childIds,
    required this.title,
    required this.description,
    required this.points,
    required this.frequency,
    required this.recurrenceDay,
    required this.category,
    required this.isAutoVerified,
  });

  Map<String, dynamic> toRequestBody() {
    return {
      'child_ids': childIds,
      'title': title,
      'description': description,
      'points': points,
      'task_frequency': frequency,
      if (recurrenceDay != null) 'recurrence_day': recurrenceDay,
      'category': category,
      'is_auto_verified': isAutoVerified,
    };
  }
}
