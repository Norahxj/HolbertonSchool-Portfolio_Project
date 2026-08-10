const List<String> kMoodValues = [
  'HAPPY',
  'PROUD',
  'GREAT',
  'LOVE',
  'STRONG',
  'STAR',
];

class DailyFeedbackModel {
  final String id;
  final String childId;
  final String createdBy;
  final String mood;
  final DateTime feedbackDate;
  final DateTime createdAt;

  const DailyFeedbackModel({
    required this.id,
    required this.childId,
    required this.createdBy,
    required this.mood,
    required this.feedbackDate,
    required this.createdAt,
  });

  factory DailyFeedbackModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DailyFeedbackModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      createdBy: json['created_by'] as String,
      mood: json['mood'] as String,
      feedbackDate: DateTime.parse(
        json['feedback_date'] as String,
      ),
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
    );
  }
}