import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/task_assignment_model.dart';
import '../models/child_task_action_result.dart';
import '../models/upcoming_child_task.dart';
import '../repositories/child_tasks_repository.dart';

class ChildTasksController extends ChangeNotifier {
  final ChildTasksRepository _repository;

  ChildTasksController({ChildTasksRepository? repository})
    : _repository = repository ?? ChildTasksRepository();

  List<TaskAssignmentModel> _tasks = [];
  List<UpcomingChildTask> _upcomingTasks = [];
  Set<String> _deletableTaskIds = {};

  final Set<String> _deletingTaskIds = {};

  String? _childId;

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isDisposed = false;

  ChildTasksErrorCode? _errorCode;
  String? _backendMessage;

  List<TaskAssignmentModel> get tasks {
    return List.unmodifiable(_tasks);
  }

  List<UpcomingChildTask> get upcomingTasks {
    return List.unmodifiable(_upcomingTasks);
  }

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  ChildTasksErrorCode? get errorCode => _errorCode;

  String? get backendMessage => _backendMessage;

  bool get hasNoTaskData {
    return _tasks.isEmpty && _upcomingTasks.isEmpty;
  }

  bool canDeleteTask(String taskId) {
    return _deletableTaskIds.contains(taskId);
  }

  bool isDeletingTask(String taskId) {
    return _deletingTaskIds.contains(taskId);
  }

  Future<void> loadTasks(String childId) async {
    if (_isLoading) {
      return;
    }

    _childId = childId;
    _isLoading = true;
    _clearError();
    _notify();

    try {
      await _loadTaskData(childId);
    } on DioException catch (error) {
      _errorCode = ChildTasksErrorCode.loadFailed;
      _backendMessage = _readBackendMessage(error);
    } catch (error, stackTrace) {
      _errorCode = ChildTasksErrorCode.loadFailed;

      debugPrint(
        'Loading child tasks failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> refresh() async {
    final childId = _childId;

    if (childId == null || _isRefreshing) {
      return;
    }

    _isRefreshing = true;
    _clearError();
    _notify();

    try {
      await _loadTaskData(childId);
    } on DioException catch (error) {
      _errorCode = ChildTasksErrorCode.refreshFailed;
      _backendMessage = _readBackendMessage(error);
    } catch (error, stackTrace) {
      _errorCode = ChildTasksErrorCode.refreshFailed;

      debugPrint(
        'Refreshing child tasks failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isRefreshing = false;
      _notify();
    }
  }

  Future<ChildTaskActionResult> deleteTask(String taskId) async {
    final childId = _childId;

    if (childId == null) {
      return const ChildTaskActionResult.failure(
        errorCode: ChildTasksErrorCode.childNotIdentified,
      );
    }

    if (!_deletableTaskIds.contains(taskId)) {
      return const ChildTaskActionResult.failure(
        errorCode: ChildTasksErrorCode.deleteNotAllowed,
      );
    }

    if (_deletingTaskIds.contains(taskId)) {
      return const ChildTaskActionResult.success();
    }

    _deletingTaskIds.add(taskId);
    _notify();

    try {
      await _repository.deleteTask(taskId);

      await _loadTaskData(childId);

      _clearError();

      return const ChildTaskActionResult.success();
    } on DioException catch (error) {
      return ChildTaskActionResult.failure(
        errorCode: ChildTasksErrorCode.deleteFailed,
        backendMessage: _readBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Deleting child task failed: '
        '$error\n$stackTrace',
      );

      return const ChildTaskActionResult.failure(
        errorCode: ChildTasksErrorCode.deleteFailed,
      );
    } finally {
      _deletingTaskIds.remove(taskId);
      _notify();
    }
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
