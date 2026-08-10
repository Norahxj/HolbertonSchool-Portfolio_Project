enum ChildTaskDetailsErrorCode {
  completeFailed,
  unexpectedError,
}

class ChildTaskDetailsActionResult {
  final bool isSuccess;
  final ChildTaskDetailsErrorCode? errorCode;
  final String? backendMessage;

  const ChildTaskDetailsActionResult._({
    required this.isSuccess,
    this.errorCode,
    this.backendMessage,
  });

  const ChildTaskDetailsActionResult.success()
    : this._(
        isSuccess: true,
      );

  const ChildTaskDetailsActionResult.failure({
    required ChildTaskDetailsErrorCode errorCode,
    String? backendMessage,
  }) : this._(
         isSuccess: false,
         errorCode: errorCode,
         backendMessage: backendMessage,
       );
}