enum ChildHomeErrorCode {
  loadFailed,
  childNotFound,
  completeTaskFailed,
  refreshFailed,
}

class ChildHomeActionResult {
  final bool isSuccess;
  final ChildHomeErrorCode? errorCode;
  final String? backendMessage;

  const ChildHomeActionResult._({
    required this.isSuccess,
    this.errorCode,
    this.backendMessage,
  });

  const ChildHomeActionResult.success()
      : this._(
          isSuccess: true,
        );

  const ChildHomeActionResult.failure({
    required ChildHomeErrorCode errorCode,
    String? backendMessage,
  }) : this._(
          isSuccess: false,
          errorCode: errorCode,
          backendMessage: backendMessage,
        );
}