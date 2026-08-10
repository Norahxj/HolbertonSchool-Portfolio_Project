import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/review_task.dart';
import '../models/task_review_action.dart';
import '../models/task_review_action_result.dart';
import '../models/task_review_error_code.dart';
import '../repositories/task_review_repository.dart';
import '../utils/task_review_error_mapper.dart';

class TaskReviewController extends ChangeNotifier {
  final TaskReviewRepository _repository;

  TaskReviewController({
    TaskReviewRepository? repository,
  }) : _repository = repository ?? TaskReviewRepository();

  final List<ReviewTask> _pendingTasks = [];

  bool _isLoading = true;

  TaskReviewErrorCode? _errorCode;
  String? _backendMessage;

  String? _updatingAssignmentId;
  TaskReviewAction? _updatingAction;

  List<ReviewTask> get pendingTasks =>
      List.unmodifiable(_pendingTasks);

  bool get isLoading => _isLoading;

  TaskReviewErrorCode? get errorCode => _errorCode;

  String? get backendMessage => _backendMessage;

  bool isUpdating(String assignmentId) {
    return _updatingAssignmentId == assignmentId;
  }

  bool isApproving(String assignmentId) {
    return isUpdating(assignmentId) &&
        _updatingAction == TaskReviewAction.approve;
  }

  bool isRetrying(String assignmentId) {
    return isUpdating(assignmentId) &&
        _updatingAction == TaskReviewAction.retry;
  }

  Future<void> loadPendingTasks() async {
    if (_isLoading && _pendingTasks.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _clearPageError();
    notifyListeners();

    try {
      final assignments =
          await _repository.getPendingReviewAssignments();

      final reviewTasks = assignments
          .where((assignment) => assignment.child != null)
          .map((assignment) {
            return ReviewTask(
              child: assignment.child!,
              assignment: assignment,
            );
          })
          .toList();

      reviewTasks.sort((first, second) {
        final firstDate = first.assignment.completedAt;
        final secondDate = second.assignment.completedAt;

        if (firstDate == null && secondDate == null) {
          return 0;
        }

        if (firstDate == null) {
          return 1;
        }

        if (secondDate == null) {
          return -1;
        }

        return secondDate.compareTo(firstDate);
      });

      _pendingTasks
        ..clear()
        ..addAll(reviewTasks);
    } on DioException catch (error) {
      debugPrint(
        'Review loading failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      _backendMessage =
          TaskReviewErrorMapper.readBackendMessage(error);

      _errorCode = TaskReviewErrorCode.loadTasks;
    } catch (error) {
      debugPrint('Review loading failed: $error');

      _errorCode = TaskReviewErrorCode.loadTasks;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TaskReviewActionResult> approveTask(
    ReviewTask item,
  ) async {
    if (_updatingAssignmentId != null) {
      return const TaskReviewActionResult();
    }

    final assignmentId = item.assignment.id;

    _updatingAssignmentId = assignmentId;
    _updatingAction = TaskReviewAction.approve;
    notifyListeners();

    try {
      await _repository.approveAssignment(assignmentId);

      _removeTask(assignmentId);

      return const TaskReviewActionResult(
        isSuccess: true,
      );
    } on DioException catch (error) {
      debugPrint(
        'Approval failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      final isNotAllowed = error.response?.statusCode == 404;

      return TaskReviewActionResult(
        errorCode: isNotAllowed
            ? TaskReviewErrorCode.approveNotAllowed
            : TaskReviewErrorCode.approveTask,
        backendMessage: isNotAllowed
            ? null
            : TaskReviewErrorMapper.readBackendMessage(error),
      );
    } catch (error) {
      debugPrint('Approval failed: $error');

      return const TaskReviewActionResult(
        errorCode: TaskReviewErrorCode.approveTask,
      );
    } finally {
      _clearUpdatingState();
      notifyListeners();
    }
  }

  Future<TaskReviewActionResult> sendBackForRetry(
    ReviewTask item,
  ) async {
    if (_updatingAssignmentId != null) {
      return const TaskReviewActionResult();
    }

    final assignmentId = item.assignment.id;

    _updatingAssignmentId = assignmentId;
    _updatingAction = TaskReviewAction.retry;
    notifyListeners();

    try {
      await _repository.rejectAssignment(assignmentId);

      _removeTask(assignmentId);

      return const TaskReviewActionResult(
        isSuccess: true,
      );
    } on DioException catch (error) {
      debugPrint(
        'Retry request failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      final isNotAllowed = error.response?.statusCode == 404;

      return TaskReviewActionResult(
        errorCode: isNotAllowed
            ? TaskReviewErrorCode.retryNotAllowed
            : TaskReviewErrorCode.retryTask,
        backendMessage: isNotAllowed
            ? null
            : TaskReviewErrorMapper.readBackendMessage(error),
      );
    } catch (error) {
      debugPrint('Retry request failed: $error');

      return const TaskReviewActionResult(
        errorCode: TaskReviewErrorCode.retryTask,
      );
    } finally {
      _clearUpdatingState();
      notifyListeners();
    }
  }

  void _removeTask(String assignmentId) {
    _pendingTasks.removeWhere(
      (task) => task.assignment.id == assignmentId,
    );
  }

  void _clearUpdatingState() {
    _updatingAssignmentId = null;
    _updatingAction = null;
  }

  void _clearPageError() {
    _errorCode = null;
    _backendMessage = null;
  }
}