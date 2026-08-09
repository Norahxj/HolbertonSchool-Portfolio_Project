import 'task_review_error_code.dart';

class TaskReviewActionResult {
  final bool isSuccess;
  final TaskReviewErrorCode? errorCode;
  final String? backendMessage;

  const TaskReviewActionResult({
    this.isSuccess = false,
    this.errorCode,
    this.backendMessage,
  });
}