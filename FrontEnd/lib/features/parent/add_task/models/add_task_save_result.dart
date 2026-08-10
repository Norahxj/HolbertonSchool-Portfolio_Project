import 'add_task_errors.dart';

class AddTaskSaveResult {
  final bool isSuccess;
  final AddTaskSaveErrorCode? errorCode;
  final String? backendMessage;

  const AddTaskSaveResult._({
    required this.isSuccess,
    this.errorCode,
    this.backendMessage,
  });

  const AddTaskSaveResult.success() : this._(isSuccess: true);

  const AddTaskSaveResult.validationFailure() : this._(isSuccess: false);

  const AddTaskSaveResult.failure({
    required AddTaskSaveErrorCode errorCode,
    String? backendMessage,
  }) : this._(
         isSuccess: false,
         errorCode: errorCode,
         backendMessage: backendMessage,
       );
}
