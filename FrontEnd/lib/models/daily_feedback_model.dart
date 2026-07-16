/// Valid mood values as defined in the backend.
const List<String> kMoodValues = [
  'HAPPY',
  'PROUD',
  'GREAT',
  'LOVE',
  'STRONG',
  'STAR',
];

/// Arabic label for each mood value.
const Map<String, String> kMoodLabels = {
  'HAPPY': 'سعيد 😊',
  'PROUD': 'فخور 🌟',
  'GREAT': 'رائع 🎉',
  'LOVE': 'محبوب ❤️',
  'STRONG': 'قوي 💪',
  'STAR': 'نجم ⭐',
};

/// Model for a daily feedback entry, matching DailyFeedbackResponseSchema.
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

  factory DailyFeedbackModel.fromJson(Map<String, dynamic> json) {
    return DailyFeedbackModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      createdBy: json['created_by'] as String,
      mood: json['mood'] as String,
      feedbackDate: DateTime.parse(json['feedback_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
