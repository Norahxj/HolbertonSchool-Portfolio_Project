/// Model for a weekend reward, matching the backend RewardResponseSchema.
///
/// [status] values: 'locked' | 'unlocked' | 'claimed'
/// [unlockDay] is an integer 0-6 (0=Sunday, 1=Monday, ..., 6=Saturday).
class RewardModel {
  final String id;
  final String childId;
  final String rewardName;
  final String? description;
  final String status;
  final int unlockDay;
  final String? assignedBy;
  final DateTime createdAt;

  const RewardModel({
    required this.id,
    required this.childId,
    required this.rewardName,
    this.description,
    required this.status,
    required this.unlockDay,
    this.assignedBy,
    required this.createdAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      rewardName: json['reward_name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      unlockDay: (json['unlock_day'] as num?)?.toInt() ?? 3,
      assignedBy: json['assigned_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Arabic label for the unlock day.
  String get unlockDayLabel {
    const days = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    if (unlockDay >= 0 && unlockDay < days.length) {
      return days[unlockDay];
    }
    return 'غير محدد';
  }
}