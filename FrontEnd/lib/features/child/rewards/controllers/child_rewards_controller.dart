import 'package:flutter/foundation.dart';

import '../../../../models/reward_model.dart';
import '../models/child_rewards_action_result.dart';
import '../repositories/child_rewards_repository.dart';

class ChildRewardsController extends ChangeNotifier {
  final ChildRewardsRepository _repository;

  ChildRewardsController({
    ChildRewardsRepository? repository,
  }) : _repository =
            repository ?? ChildRewardsRepository();

  List<RewardModel> _rewards = [];

  bool _isLoading = false;
  bool _isDisposed = false;

  ChildRewardsErrorCode? _errorCode;

  List<RewardModel> get rewards {
    return List.unmodifiable(_rewards);
  }

  bool get isLoading => _isLoading;

  ChildRewardsErrorCode? get errorCode => _errorCode;

  bool get hasError => _errorCode != null;

  Future<void> loadRewards() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorCode = null;
    _notify();

    try {
      _rewards = await _repository.getRewards();
    } catch (error, stackTrace) {
      _errorCode = ChildRewardsErrorCode.loadFailed;

      debugPrint(
        'Loading child rewards failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<ChildRewardsActionResult> claimReward(
    String rewardId,
  ) async {
    try {
      await _repository.claimReward(rewardId);

      await loadRewards();

      return const ChildRewardsActionResult.success();
    } catch (error, stackTrace) {
      debugPrint(
        'Claiming child reward failed: '
        '$error\n$stackTrace',
      );

      return const ChildRewardsActionResult.failure(
        errorCode: ChildRewardsErrorCode.claimFailed,
      );
    }
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}