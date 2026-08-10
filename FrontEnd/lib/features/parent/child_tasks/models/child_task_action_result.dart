enum ChildTasksErrorCode {
  loadFailed,
  refreshFailed,
  childNotIdentified,
  deleteNotAllowed,
  deleteFailed,
}

class ChildTaskActionResult {
  final ChildTasksErrorCode? errorCode;
  final String? backendMessage;

  const ChildTaskActionResult._({this.errorCode, this.backendMessage});

  const ChildTaskActionResult.success() : this._();

  const ChildTaskActionResult.failure({
    required ChildTasksErrorCode errorCode,
    String? backendMessage,
  }) : this._(errorCode: errorCode, backendMessage: backendMessage);

  bool get isSuccess => errorCode == null;
}
