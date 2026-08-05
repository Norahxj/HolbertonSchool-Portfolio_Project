import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../services/task_api_service.dart';
import '../models/review_task.dart';

class TaskReviewController extends ChangeNotifier {
  final TaskApiService _taskApiService;

  TaskReviewController({required this.isArabic, TaskApiService? taskApiService})
    : _taskApiService = taskApiService ?? TaskApiService();

  final bool isArabic;

  final List<ReviewTask> _pendingTasks = [];

  List<ReviewTask> get pendingTasks => List.unmodifiable(_pendingTasks);

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  String? _updatingAssignmentId;

  String? get updatingAssignmentId => _updatingAssignmentId;

  String? _updatingAction;

  String? get updatingAction => _updatingAction;

  String tr(String arabic, String english) {
    return isArabic ? arabic : english;
  }

  Future<void> loadPendingTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final assignments = await _taskApiService.getPendingReviewAssignments();

      final reviewTasks = assignments
          .where((assignment) => assignment.child != null)
          .map(
            (assignment) =>
                ReviewTask(child: assignment.child!, assignment: assignment),
          )
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

      _errorMessage =
          _readBackendMessage(error) ??
          tr('تعذر تحميل المهام', 'Unable to load tasks');
    } catch (error) {
      debugPrint('Review loading failed: $error');

      _errorMessage = tr('تعذر تحميل المهام', 'Unable to load tasks');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> approveTask(ReviewTask item) async {
    if (_updatingAssignmentId != null) {
      return null;
    }

    _updatingAssignmentId = item.assignment.id;
    _updatingAction = 'approve';
    notifyListeners();

    try {
      await _taskApiService.approveAssignment(item.assignment.id);

      _pendingTasks.removeWhere(
        (task) => task.assignment.id == item.assignment.id,
      );

      notifyListeners();

      return null;
    } on DioException catch (error) {
      debugPrint(
        'Approval failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      final statusCode = error.response?.statusCode;

      if (statusCode == 404) {
        return tr(
          'لا يمكنك قبول هذه المهمة؛ يمكن قبولها فقط بواسطة ولي الأمر الذي أضافها.',
          'Only the guardian who created this task can accept it.',
        );
      }

      return _readBackendMessage(error) ??
          tr('تعذر قبول المهمة', 'Unable to accept the task');
    } catch (error) {
      debugPrint('Approval failed: $error');

      return tr('تعذر قبول المهمة', 'Unable to accept the task');
    } finally {
      _updatingAssignmentId = null;
      _updatingAction = null;
      notifyListeners();
    }
  }

  Future<String?> sendBackForRetry(ReviewTask item) async {
    if (_updatingAssignmentId != null) {
      return null;
    }

    _updatingAssignmentId = item.assignment.id;
    _updatingAction = 'retry';
    notifyListeners();

    try {
      await _taskApiService.rejectAssignment(item.assignment.id);

      _pendingTasks.removeWhere(
        (task) => task.assignment.id == item.assignment.id,
      );

      notifyListeners();

      return null;
    } on DioException catch (error) {
      debugPrint(
        'Retry request failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      final statusCode = error.response?.statusCode;

      if (statusCode == 404) {
        return tr(
          'لا يمكنك إرسال هذه المهمة لإعادة المحاولة؛ يمكن ذلك فقط بواسطة ولي الأمر الذي أضافها.',
          'Only the guardian who created this task can send it back for another try.',
        );
      }

      return _readBackendMessage(error) ??
          tr(
            'تعذر إرسال المهمة لإعادة المحاولة',
            'Unable to send the task back for another try',
          );
    } catch (error) {
      debugPrint('Retry request failed: $error');

      return tr(
        'تعذر إرسال المهمة لإعادة المحاولة',
        'Unable to send the task back for another try',
      );
    } finally {
      _updatingAssignmentId = null;
      _updatingAction = null;
      notifyListeners();
    }
  }

  bool isUpdating(String assignmentId) {
    return _updatingAssignmentId == assignmentId;
  }

  bool isApproving(String assignmentId) {
    return isUpdating(assignmentId) && _updatingAction == 'approve';
  }

  bool isRetrying(String assignmentId) {
    return isUpdating(assignmentId) && _updatingAction == 'retry';
  }

  String formatCompletedTime(DateTime? completedAt) {
    if (completedAt == null) {
      return tr('أُنجزت مؤخرًا', 'Completed recently');
    }

    final date = completedAt.toLocal();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return tr('أُنجزت في $hour:$minute', 'Completed at $hour:$minute');
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString();
    }

    return null;
  }
}
