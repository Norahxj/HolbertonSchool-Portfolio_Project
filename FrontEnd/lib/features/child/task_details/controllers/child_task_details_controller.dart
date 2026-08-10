import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/task_assignment_model.dart';
import '../models/child_task_details_action_result.dart';
import '../repositories/child_task_details_repository.dart';

class ChildTaskDetailsController extends ChangeNotifier {
  final ChildTaskDetailsRepository _repository;

  ChildTaskDetailsController({
    ChildTaskDetailsRepository? repository,
  }) : _repository = repository ?? ChildTaskDetailsRepository();

  late TaskAssignmentModel _assignment;

  String _status = '';
  bool _isSubmitting = false;
  bool _isDisposed = false;

  TaskAssignmentModel get assignment => _assignment;

  String get status => _status;

  bool get isSubmitting => _isSubmitting;

  bool get canComplete {
    return _status == 'PENDING' || _status == 'REJECTED';
  }

  bool get isPendingReview {
    return _status == 'PENDING_REVIEW' || _status == 'COMPLETED';
  }

  bool get isApproved {
    return _status == 'APPROVED';
  }

  bool get isRejected {
    return _status == 'REJECTED';
  }

  void initialize(TaskAssignmentModel assignment) {
    _assignment = assignment;
    _status = assignment.normalizedStatus;
  }

  Future<ChildTaskDetailsActionResult> completeTask() async {
    if (!canComplete || _isSubmitting) {
      return const ChildTaskDetailsActionResult.success();
    }

    _isSubmitting = true;
    _notify();

    try {
      await _repository.completeAssignment(_assignment.id);

      if (_assignment.task.isAutoVerified) {
        _status = 'APPROVED';
      } else {
        _status = 'PENDING_REVIEW';
      }

      return const ChildTaskDetailsActionResult.success();
    } on DioException catch (error) {
      return ChildTaskDetailsActionResult.failure(
        errorCode: ChildTaskDetailsErrorCode.completeFailed,
        backendMessage: _readBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Complete assignment failed: '
        '$error\n$stackTrace',
      );

      return const ChildTaskDetailsActionResult.failure(
        errorCode: ChildTaskDetailsErrorCode.unexpectedError,
      );
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is! Map) {
      return null;
    }

    final errorMessage = data['error']?.toString().trim();

    if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }

    final message = data['message']?.toString().trim();

    if (message == null || message.isEmpty) {
      return null;
    }

    return message;
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}