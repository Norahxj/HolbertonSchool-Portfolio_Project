enum AuthErrorCode {
  loginFailed,
  registerFailed,
  unexpectedError,
}

class AuthActionResult {
  final bool isSuccess;
  final AuthErrorCode? errorCode;
  final String? backendMessage;
  final Map<String, String> fieldErrors;

  const AuthActionResult._({
    required this.isSuccess,
    this.errorCode,
    this.backendMessage,
    this.fieldErrors = const {},
  });

  const AuthActionResult.success()
      : this._(
          isSuccess: true,
        );

  const AuthActionResult.failure({
    required AuthErrorCode errorCode,
    String? backendMessage,
    Map<String, String> fieldErrors = const {},
  }) : this._(
          isSuccess: false,
          errorCode: errorCode,
          backendMessage: backendMessage,
          fieldErrors: fieldErrors,
        );
}