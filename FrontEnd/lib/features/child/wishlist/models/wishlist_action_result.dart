enum WishlistErrorCode {
  loadFailed,
  deleteFailed,
  achieveFailed,
  createFailed,
  wishlistLimitReached,
  nameTooShort,
  nameTooLong,
}

class WishlistActionResult {
  final bool isSuccess;
  final WishlistErrorCode? errorCode;
  final String? backendMessage;

  const WishlistActionResult._({
    required this.isSuccess,
    this.errorCode,
    this.backendMessage,
  });

  const WishlistActionResult.success()
      : this._(
          isSuccess: true,
        );

  const WishlistActionResult.failure({
    required WishlistErrorCode errorCode,
    String? backendMessage,
  }) : this._(
          isSuccess: false,
          errorCode: errorCode,
          backendMessage: backendMessage,
        );
}