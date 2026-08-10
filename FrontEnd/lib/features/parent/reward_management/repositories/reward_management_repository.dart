import '../../../../models/child_model.dart';
import '../../../../models/reward_model.dart';
import '../../../../models/reward_suggestion_model.dart';
import '../../../../services/reward_api_service.dart';
import '../../services/child_api_service.dart';

class RewardManagementRepository {
  final ChildApiService _childApiService;
  final RewardApiService _rewardApiService;

  RewardManagementRepository({
    ChildApiService? childApiService,
    RewardApiService? rewardApiService,
  }) : _childApiService = childApiService ?? ChildApiService(),
       _rewardApiService = rewardApiService ?? RewardApiService();

  Future<List<ChildModel>> getChildren() {
    return _childApiService.getChildren();
  }

  Future<List<RewardModel>> getRewardsForChild(String childId) {
    return _rewardApiService.getRewardsForChild(childId);
  }

  Future<List<RewardSuggestionModel>> getRewardSuggestions({
    required String languageCode,
    int count = 5,
  }) {
    return _rewardApiService.getRewardSuggestions(
      lang: languageCode,
      count: count,
    );
  }

  Future<void> deleteReward(String rewardId) {
    return _rewardApiService.deleteReward(rewardId);
  }
}
