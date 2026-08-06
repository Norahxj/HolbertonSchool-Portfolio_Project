enum RewardManagementErrorCode {
  loadChildren,
  loadRewards,
  loadSuggestions,
  deleteNotAllowed,
  deleteClaimedReward,
  deleteReward,
}

class RewardDeleteResult {
  final RewardManagementErrorCode? errorCode;
  final String? backendMessage;

  const RewardDeleteResult._({this.errorCode, this.backendMessage});

  const RewardDeleteResult.success() : this._();

  const RewardDeleteResult.failure({
    required RewardManagementErrorCode errorCode,
    String? backendMessage,
  }) : this._(errorCode: errorCode, backendMessage: backendMessage);

  bool get isSuccess => errorCode == null;
}
