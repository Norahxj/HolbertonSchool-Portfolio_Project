enum ParentChildDetailsErrorCode {
  loadTasks,
  refreshTasks,
  childNotIdentified,
  taskDeleteNotAllowed,
  deleteTask,
  deleteChild,
  childNotFound,
  parentNotFound,
  parentAccessRequired,
  deleteChildRelatedData,
}

class ParentChildDetailsActionResult {
  final ParentChildDetailsErrorCode? errorCode;
  final String? backendMessage;

  const ParentChildDetailsActionResult._({this.errorCode, this.backendMessage});

  const ParentChildDetailsActionResult.success() : this._();

  const ParentChildDetailsActionResult.failure({
    required ParentChildDetailsErrorCode errorCode,
    String? backendMessage,
  }) : this._(errorCode: errorCode, backendMessage: backendMessage);

  bool get isSuccess => errorCode == null;
}
