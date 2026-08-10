enum WishlistActionErrorCode { approveFailed, rejectFailed }

class WishlistActionResult {
  final WishlistActionErrorCode? errorCode;

  const WishlistActionResult._({this.errorCode});

  const WishlistActionResult.success() : this._();

  const WishlistActionResult.failure(WishlistActionErrorCode errorCode)
    : this._(errorCode: errorCode);

  bool get isSuccess => errorCode == null;
}
