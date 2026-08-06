import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../services/task_api_service.dart';
import '../models/review_task.dart';

enum TaskReviewErrorCode {
  loadTasks,
  approveTask,
  approveNotAllowed,
  retryTask,
  retryNotAllowed,
}

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

class TaskReviewController extends ChangeNotifier {
  final TaskApiService _taskApiService;

  TaskReviewController({TaskApiService? taskApiService})
    : _taskApiService = taskApiService ?? TaskApiService();

  final List<ReviewTask> _pendingTasks = [];

  bool _isLoading = true;

  TaskReviewErrorCode? _errorCode;
  String? _backendMessage;

  String? _updatingAssignmentId;
  TaskReviewAction? _updatingAction;

  List<ReviewTask> get pendingTasks {
    return List.unmodifiable(_pendingTasks);
  }

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
      final assignments = await _taskApiService.getPendingReviewAssignments();

      final reviewTasks = assignments
          .where((assignment) => assignment.child != null)
          .map((assignment) {
            return ReviewTask(child: assignment.child!, assignment: assignment);
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

      _backendMessage = _readBackendMessage(error);
      _errorCode = TaskReviewErrorCode.loadTasks;
    } catch (error) {
      debugPrint('Review loading failed: $error');

      _errorCode = TaskReviewErrorCode.loadTasks;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TaskReviewActionResult> approveTask(ReviewTask item) async {
    if (_updatingAssignmentId != null) {
      return const TaskReviewActionResult();
    }

    _updatingAssignmentId = item.assignment.id;
    _updatingAction = TaskReviewAction.approve;
    notifyListeners();

    try {
      await _taskApiService.approveAssignment(item.assignment.id);

      _removeTask(item.assignment.id);

      return const TaskReviewActionResult(isSuccess: true);
    } on DioException catch (error) {
      debugPrint(
        'Approval failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      return TaskReviewActionResult(
        errorCode: error.response?.statusCode == 404
            ? TaskReviewErrorCode.approveNotAllowed
            : TaskReviewErrorCode.approveTask,
        backendMessage: error.response?.statusCode == 404
            ? null
            : _readBackendMessage(error),
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

  Future<TaskReviewActionResult> sendBackForRetry(ReviewTask item) async {
    if (_updatingAssignmentId != null) {
      return const TaskReviewActionResult();
    }

    _updatingAssignmentId = item.assignment.id;
    _updatingAction = TaskReviewAction.retry;
    notifyListeners();

    try {
      await _taskApiService.rejectAssignment(item.assignment.id);

      _removeTask(item.assignment.id);

      return const TaskReviewActionResult(isSuccess: true);
    } on DioException catch (error) {
      debugPrint(
        'Retry request failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      return TaskReviewActionResult(
        errorCode: error.response?.statusCode == 404
            ? TaskReviewErrorCode.retryNotAllowed
            : TaskReviewErrorCode.retryTask,
        backendMessage: error.response?.statusCode == 404
            ? null
            : _readBackendMessage(error),
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
    _pendingTasks.removeWhere((task) => task.assignment.id == assignmentId);
  }

  void _clearUpdatingState() {
    _updatingAssignmentId = null;
    _updatingAction = null;
  }

  void _clearPageError() {
    _errorCode = null;
    _backendMessage = null;
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString();
    }

    return null;
  }
}

enum TaskReviewAction { approve, retry }
