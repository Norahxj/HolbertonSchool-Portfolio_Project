import '../core/network/api_service.dart';
import '../core/network/dio_factory.dart';
import '../models/reward_model.dart';
import '../models/reward_suggestion_model.dart';

class RewardApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  Future<List<RewardSuggestionModel>> getRewardSuggestions({
    String lang = 'ar',
    int count = 5,
  }) async {
    final response = await _apiService.getRewardBankSuggestions({
      'lang': lang,
      'count': count,
    });

    final responseData = response.data as Map<String, dynamic>;

    final suggestions = responseData['suggestions'] as List<dynamic>? ?? [];

    return suggestions.map((json) {
      return RewardSuggestionModel.fromJson(json as Map<String, dynamic>);
    }).toList();
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
      if (description != null && description.isNotEmpty)
        'description': description,
      'unlock_day': unlockDay,
    });

    return RewardModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<RewardModel>> getRewardsForChild(String childId) async {
    final response = await _apiService.getRewardsForChild(childId);

    final data = response.data as List<dynamic>;

    return data.map((json) {
      return RewardModel.fromJson(json as Map<String, dynamic>);
    }).toList();
  }

  Future<void> deleteReward(String rewardId) async {
    await _apiService.deleteReward(rewardId);
  }

  Future<List<RewardModel>> getMyRewards() async {
    final response = await _apiService.getMyRewards();

    final data = response.data as List<dynamic>;

    return data.map((json) {
      return RewardModel.fromJson(json as Map<String, dynamic>);
    }).toList();
  }

  Future<RewardModel> claimReward(String rewardId) async {
    final response = await _apiService.claimReward(rewardId);

    return RewardModel.fromJson(response.data as Map<String, dynamic>);
  }
}
