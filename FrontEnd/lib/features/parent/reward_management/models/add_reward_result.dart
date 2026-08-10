enum AddRewardErrorCode { rewardNameRequired, saveReward, genericSaveReward }

class AddRewardResult {
  final AddRewardErrorCode? errorCode;
  final String? backendMessage;

  const AddRewardResult._({this.errorCode, this.backendMessage});

  const AddRewardResult.success() : this._();

  const AddRewardResult.failure({
    required AddRewardErrorCode errorCode,
    String? backendMessage,
  }) : this._(errorCode: errorCode, backendMessage: backendMessage);

  bool get isSuccess => errorCode == null;
}
