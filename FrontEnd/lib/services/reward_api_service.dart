import '../core/network/api_service.dart';
import '../core/network/dio_factory.dart';
import '../models/reward_model.dart';
import '../models/reward_suggestion_model.dart';

class RewardApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  /// Parent: create a reward for a child.
  /// [unlockDay] 0=Sunday … 6=Saturday, defaults to 3 (Wednesday).
  Future<List<RewardSuggestionModel>> getRewardSuggestions({
  String lang = 'ar',
  int count = 5,
}) async {
  final response = await _apiService.getRewardBankSuggestions({
    'lang': lang,
    'count': count,
  });

  final responseData = response.data as Map<String, dynamic>;

  final List<dynamic> suggestions =
      responseData['suggestions'] as List<dynamic>? ?? [];

  return suggestions
      .map(
        (json) => RewardSuggestionModel.fromJson(
          json as Map<String, dynamic>,
        ),
      )
      .toList();
}
  Future<RewardModel> createReward({
    required String childId,
    required String rewardName,
    String? description,
    int unlockDay = 3,
  }) async {
    final response = await _apiService.createReward({
      'child_id': childId,
      'reward_name': rewardName,
      if (description != null) 'description': description,
      'unlock_day': unlockDay,
    });
    return RewardModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Parent: get all rewards for a specific child.
  Future<List<RewardModel>> getRewardsForChild(String childId) async {
    final response = await _apiService.getRewardsForChild(childId);
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => RewardModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Parent: delete a reward (only if not yet claimed).
  Future<void> deleteReward(String rewardId) async {
    await _apiService.deleteReward(rewardId);
  }

  /// Child: get my own rewards.
  Future<List<RewardModel>> getMyRewards() async {
    final response = await _apiService.getMyRewards();
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => RewardModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Child: claim an unlocked reward.
  Future<RewardModel> claimReward(String rewardId) async {
    final response = await _apiService.claimReward(rewardId);
    return RewardModel.fromJson(response.data as Map<String, dynamic>);
  }
}
