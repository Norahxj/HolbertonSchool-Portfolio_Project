import '../../../../models/reward_model.dart';
import '../../../../services/reward_api_service.dart';

class ChildRewardsRepository {
  final RewardApiService _rewardApiService;

  ChildRewardsRepository({
    RewardApiService? rewardApiService,
  }) : _rewardApiService =
            rewardApiService ?? RewardApiService();

  Future<List<RewardModel>> getRewards() async {
    return _rewardApiService.getMyRewards();
  }

  Future<void> claimReward(String rewardId) async {
    await _rewardApiService.claimReward(rewardId);
  }
}