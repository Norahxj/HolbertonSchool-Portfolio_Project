import '../../../../services/reward_api_service.dart';

class AddRewardRepository {
  final RewardApiService _rewardApiService;

  AddRewardRepository({RewardApiService? rewardApiService})
    : _rewardApiService = rewardApiService ?? RewardApiService();

  Future<void> createReward({
    required String childId,
    required String rewardName,
    required String? description,
    required int unlockDay,
  }) {
    return _rewardApiService.createReward(
      childId: childId,
      rewardName: rewardName,
      description: description,
      unlockDay: unlockDay,
    );
  }
}
