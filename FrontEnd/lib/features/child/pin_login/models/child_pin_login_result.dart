enum ChildPinLoginErrorCode {
  incompleteCode,
  invalidCode,
  loginFailed,
}

class ChildPinLoginResult {
  final bool isSuccess;
  final ChildPinLoginErrorCode? errorCode;
  final String? backendMessage;

  const ChildPinLoginResult._({
    required this.isSuccess,
    this.errorCode,
    this.backendMessage,
  });

  const ChildPinLoginResult.success()
      : this._(
          isSuccess: true,
        );

  const ChildPinLoginResult.failure({
    required ChildPinLoginErrorCode errorCode,
    String? backendMessage,
  }) : this._(
          isSuccess: false,
          errorCode: errorCode,
          backendMessage: backendMessage,
        );
}