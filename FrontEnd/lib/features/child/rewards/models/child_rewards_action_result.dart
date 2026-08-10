enum ChildRewardsErrorCode {
  loadFailed,
  claimFailed,
}

class ChildRewardsActionResult {
  final bool isSuccess;
  final ChildRewardsErrorCode? errorCode;

  const ChildRewardsActionResult._({
    required this.isSuccess,
    this.errorCode,
  });

  const ChildRewardsActionResult.success()
      : this._(
          isSuccess: true,
        );

  const ChildRewardsActionResult.failure({
    required ChildRewardsErrorCode errorCode,
  }) : this._(
          isSuccess: false,
          errorCode: errorCode,
        );
}