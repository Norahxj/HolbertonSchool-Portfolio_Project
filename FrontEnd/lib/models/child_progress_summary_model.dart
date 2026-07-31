class ChildProgressSummaryModel {
  final int totalCompleted;
  final int currentStreak;
  final Map<String, int> completedByCategory;

  const ChildProgressSummaryModel({
    required this.totalCompleted,
    required this.currentStreak,
    required this.completedByCategory,
  });

  factory ChildProgressSummaryModel.fromJson(Map<String, dynamic> json) {
    final categoryData =
        json['completed_by_category'] as Map<String, dynamic>? ?? {};

    return ChildProgressSummaryModel(
      totalCompleted: (json['total_completed'] as num?)?.toInt() ?? 0,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      completedByCategory: categoryData.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      ),
    );
  }
}
