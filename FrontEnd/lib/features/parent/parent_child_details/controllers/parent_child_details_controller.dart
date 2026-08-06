import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/task_assignment_model.dart';
import '../models/parent_child_tasks_data.dart';
import '../repositories/parent_child_details_repository.dart';

enum ParentChildDetailsErrorCode {
  loadTasks,
  refreshTasks,
  childNotIdentified,
  taskDeleteNotAllowed,
  deleteTask,
}

class ParentChildDetailsController extends ChangeNotifier {
  final ParentChildDetailsRepository _repository;

  ParentChildDetailsController(this._repository);

  List<TaskAssignmentModel> _tasks = [];
  List<UpcomingTaskItem> _upcomingTasks = [];
  Set<String> _deletableTaskIds = {};

  bool _isLoading = false;
  bool _isRefreshing = false;

  ParentChildDetailsErrorCode? _errorCode;
  String? _backendMessage;
  String? _childId;

  List<TaskAssignmentModel> get tasks => List.unmodifiable(_tasks);

  List<UpcomingTaskItem> get upcomingTasks => List.unmodifiable(_upcomingTasks);

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  ParentChildDetailsErrorCode? get errorCode => _errorCode;

  String? get backendMessage => _backendMessage;

  bool get hasNoTaskData => _tasks.isEmpty && _upcomingTasks.isEmpty;

  bool canDeleteTask(String taskId) {
    return _deletableTaskIds.contains(taskId);
  }

  Future<void> loadTasks(String childId) async {
    if (_isLoading) {
      return;
    }

    _childId = childId;
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _loadTaskData(childId);
    } on DioException catch (error) {
      _backendMessage = _readBackendMessage(error);
      _errorCode = ParentChildDetailsErrorCode.loadTasks;
    } catch (error) {
      _errorCode = ParentChildDetailsErrorCode.loadTasks;

      debugPrint('Loading child tasks failed: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final childId = _childId;

    if (childId == null || _isRefreshing) {
      return;
    }

    _isRefreshing = true;
    _clearError();
    notifyListeners();

    try {
      await _loadTaskData(childId);
    } on DioException catch (error) {
      _backendMessage = _readBackendMessage(error);
      _errorCode = ParentChildDetailsErrorCode.refreshTasks;
    } catch (error) {
      _errorCode = ParentChildDetailsErrorCode.refreshTasks;

      debugPrint('Refreshing child tasks failed: $error');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<ParentChildTaskDeleteResult> deleteTask(String taskId) async {
    final childId = _childId;

    if (childId == null) {
      return const ParentChildTaskDeleteResult(
        errorCode: ParentChildDetailsErrorCode.childNotIdentified,
      );
    }

    if (!_deletableTaskIds.contains(taskId)) {
      return const ParentChildTaskDeleteResult(
        errorCode: ParentChildDetailsErrorCode.taskDeleteNotAllowed,
      );
    }

    try {
      await _repository.deleteTask(taskId);
      await _loadTaskData(childId);

      _clearError();
      notifyListeners();

      return const ParentChildTaskDeleteResult(isSuccess: true);
    } on DioException catch (error) {
      return ParentChildTaskDeleteResult(
        errorCode: ParentChildDetailsErrorCode.deleteTask,
        backendMessage: _readBackendMessage(error),
      );
    } catch (error) {
      debugPrint('Deleting task failed: $error');

      return const ParentChildTaskDeleteResult(
        errorCode: ParentChildDetailsErrorCode.deleteTask,
      );
    }
  }

  void clearError() {
    if (_errorCode == null && _backendMessage == null) {
      return;
    }

    _clearError();
    notifyListeners();
  }

  Future<void> _loadTaskData(String childId) async {
    final data = await _repository.getChildTasksData(childId);

    _tasks = data.assignments;
    _upcomingTasks = data.upcomingTasks;
    _deletableTaskIds = data.deletableTaskIds;
  }

  void _clearError() {
    _errorCode = null;
    _backendMessage = null;
  }

  String? _readBackendMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      return responseData['error']?.toString() ??
          responseData['message']?.toString();
    }

    return null;
  }
}

class ParentChildTaskDeleteResult {
  final bool isSuccess;
  final ParentChildDetailsErrorCode? errorCode;
  final String? backendMessage;

  const ParentChildTaskDeleteResult({
    this.isSuccess = false,
    this.errorCode,
    this.backendMessage,
  });
}
