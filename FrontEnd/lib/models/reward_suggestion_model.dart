class RewardSuggestionModel {
  final String rewardName;
  final String description;
  final int unlockDay;

  const RewardSuggestionModel({
    required this.rewardName,
    required this.description,
    required this.unlockDay,
  });

  factory RewardSuggestionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RewardSuggestionModel(
      rewardName: json['reward_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      unlockDay: (json['unlock_day'] as num?)?.toInt() ?? 3,
    );
  }
}