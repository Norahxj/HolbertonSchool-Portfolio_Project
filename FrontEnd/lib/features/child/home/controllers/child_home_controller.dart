import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/child_model.dart';
import '../../../../models/daily_feedback_model.dart';
import '../../../../models/task_assignment_model.dart';
import '../models/child_home_action_result.dart';
import '../repositories/child_home_repository.dart';

class ChildHomeController extends ChangeNotifier {
  final ChildHomeRepository _repository;

  ChildHomeController({
    ChildHomeRepository? repository,
  }) : _repository = repository ?? ChildHomeRepository();

  ChildModel? _child;
  List<TaskAssignmentModel> _assignments = [];
  DailyFeedbackModel? _todayFeedback;
  int _points = 0;

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isDisposed = false;

  ChildHomeErrorCode? _errorCode;
  String? _backendMessage;

  final Set<String> _updatingAssignmentIds = {};

  ChildModel? get child => _child;

  List<TaskAssignmentModel> get assignments {
    return List.unmodifiable(_assignments);
  }

  DailyFeedbackModel? get todayFeedback => _todayFeedback;

  int get points => _points;

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  ChildHomeErrorCode? get errorCode => _errorCode;

  String? get backendMessage => _backendMessage;

  bool get hasError => _errorCode != null;

  int get completedCount {
    return _assignments
        .where((assignment) => assignment.normalizedStatus == 'APPROVED')
        .length;
  }

  bool isUpdatingAssignment(String assignmentId) {
    return _updatingAssignmentIds.contains(assignmentId);
  }

  bool canCompleteAssignment(TaskAssignmentModel assignment) {
    final status = assignment.normalizedStatus;

    return status == 'PENDING' || status == 'REJECTED';
  }

  Future<void> loadHome() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _clearError();
    _notify();

    try {
      final data = await _repository.getHomeData();

      if (data == null) {
        _errorCode = ChildHomeErrorCode.childNotFound;
        return;
      }

      _child = data.child;
      _assignments = data.assignments;
      _todayFeedback = data.todayFeedback;
      _points = data.points;
    } on DioException catch (error) {
      _errorCode = ChildHomeErrorCode.loadFailed;
      _backendMessage = _readBackendMessage(error);
    } catch (error, stackTrace) {
      _errorCode = ChildHomeErrorCode.loadFailed;

      debugPrint(
        'Child home loading failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> refresh() async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    _clearError();
    _notify();

    try {
      final data = await _repository.getHomeData();

      if (data == null) {
        _errorCode = ChildHomeErrorCode.childNotFound;
        return;
      }

      _child = data.child;
      _assignments = data.assignments;
      _todayFeedback = data.todayFeedback;
      _points = data.points;
    } on DioException catch (error) {
      _errorCode = ChildHomeErrorCode.refreshFailed;
      _backendMessage = _readBackendMessage(error);
    } catch (error, stackTrace) {
      _errorCode = ChildHomeErrorCode.refreshFailed;

      debugPrint(
        'Child home refresh failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isRefreshing = false;
      _notify();
    }
  }

  Future<ChildHomeActionResult> completeAssignment(
    String assignmentId,
  ) async {
    if (_updatingAssignmentIds.contains(assignmentId)) {
      return const ChildHomeActionResult.success();
    }

    _updatingAssignmentIds.add(assignmentId);
    _notify();

    try {
      await _repository.completeAssignment(assignmentId);

      await _refreshTasksAndPoints();

      return const ChildHomeActionResult.success();
    } on DioException catch (error) {
      return ChildHomeActionResult.failure(
        errorCode: ChildHomeErrorCode.completeTaskFailed,
        backendMessage: _readBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Complete child assignment failed: '
        '$error\n$stackTrace',
      );

      return const ChildHomeActionResult.failure(
        errorCode: ChildHomeErrorCode.completeTaskFailed,
      );
    } finally {
      _updatingAssignmentIds.remove(assignmentId);
      _notify();
    }
  }

  Future<void> refreshTasksAndPoints() async {
    await _refreshTasksAndPoints();
    _notify();
  }

  Future<void> _refreshTasksAndPoints() async {
    final results = await Future.wait([
      _repository.getAssignments(),
      _repository.getPoints(),
    ]);

    _assignments = results[0] as List<TaskAssignmentModel>;
    _points = results[1] as int;
  }

  void _clearError() {
    _errorCode = null;
    _backendMessage = null;
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