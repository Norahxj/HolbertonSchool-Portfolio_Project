import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/task_assignment_model.dart';
import '../models/parent_child_details_action_result.dart';
import '../models/parent_child_tasks_data.dart';
import '../repositories/parent_child_details_repository.dart';

class ParentChildDetailsController extends ChangeNotifier {
  final ParentChildDetailsRepository _repository;

  ParentChildDetailsController({ParentChildDetailsRepository? repository})
    : _repository = repository ?? ParentChildDetailsRepository();

  List<TaskAssignmentModel> _tasks = [];
  List<UpcomingTaskItem> _upcomingTasks = [];
  Set<String> _deletableTaskIds = {};

  final Set<String> _deletingTaskIds = {};

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isDeletingChild = false;
  bool _isDisposed = false;

  ParentChildDetailsErrorCode? _errorCode;
  String? _backendMessage;
  String? _childId;

  List<TaskAssignmentModel> get tasks {
    return List.unmodifiable(_tasks);
  }

  List<UpcomingTaskItem> get upcomingTasks {
    return List.unmodifiable(_upcomingTasks);
  }

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  bool get isDeletingChild => _isDeletingChild;

  ParentChildDetailsErrorCode? get errorCode {
    return _errorCode;
  }

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
      _backendMessage = _readBackendMessage(error);
      _errorCode = ParentChildDetailsErrorCode.loadTasks;
    } catch (error, stackTrace) {
      _errorCode = ParentChildDetailsErrorCode.loadTasks;

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
      _backendMessage = _readBackendMessage(error);
      _errorCode = ParentChildDetailsErrorCode.refreshTasks;
    } catch (error, stackTrace) {
      _errorCode = ParentChildDetailsErrorCode.refreshTasks;

      debugPrint(
        'Refreshing child tasks failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isRefreshing = false;
      _notify();
    }
  }

  Future<ParentChildDetailsActionResult> deleteTask(String taskId) async {
    final childId = _childId;

    if (childId == null) {
      return const ParentChildDetailsActionResult.failure(
        errorCode: ParentChildDetailsErrorCode.childNotIdentified,
      );
    }

    if (!_deletableTaskIds.contains(taskId)) {
      return const ParentChildDetailsActionResult.failure(
        errorCode: ParentChildDetailsErrorCode.taskDeleteNotAllowed,
      );
    }

    if (_deletingTaskIds.contains(taskId)) {
      return const ParentChildDetailsActionResult.success();
    }

    _deletingTaskIds.add(taskId);
    _notify();

    try {
      await _repository.deleteTask(taskId);
      await _loadTaskData(childId);

      _clearError();

      return const ParentChildDetailsActionResult.success();
    } on DioException catch (error) {
      return ParentChildDetailsActionResult.failure(
        errorCode: ParentChildDetailsErrorCode.deleteTask,
        backendMessage: _readBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Deleting task failed: '
        '$error\n$stackTrace',
      );

      return const ParentChildDetailsActionResult.failure(
        errorCode: ParentChildDetailsErrorCode.deleteTask,
      );
    } finally {
      _deletingTaskIds.remove(taskId);
      _notify();
    }
  }

  Future<ParentChildDetailsActionResult> deleteChild() async {
    final childId = _childId;

    if (childId == null) {
      return const ParentChildDetailsActionResult.failure(
        errorCode: ParentChildDetailsErrorCode.childNotIdentified,
      );
    }

    if (_isDeletingChild) {
      return const ParentChildDetailsActionResult.success();
    }

    _isDeletingChild = true;
    _clearError();
    _notify();

    try {
      await _repository.deleteChild(childId);

      return const ParentChildDetailsActionResult.success();
    } on DioException catch (error) {
      final backendMessage = _readBackendMessage(error);

      return ParentChildDetailsActionResult.failure(
        errorCode: _mapDeleteChildError(backendMessage),
        backendMessage: backendMessage,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Deleting child failed: '
        '$error\n$stackTrace',
      );

      return const ParentChildDetailsActionResult.failure(
        errorCode: ParentChildDetailsErrorCode.deleteChild,
      );
    } finally {
      _isDeletingChild = false;
      _notify();
    }
  }

  void clearError() {
    if (_errorCode == null && _backendMessage == null) {
      return;
    }

    _clearError();
    _notify();
  }

  Future<void> _loadTaskData(String childId) async {
    final data = await _repository.getChildTasksData(childId);

    _tasks = data.assignments;
    _upcomingTasks = data.upcomingTasks;
    _deletableTaskIds = data.deletableTaskIds;
  }

  ParentChildDetailsErrorCode _mapDeleteChildError(String? backendMessage) {
    switch (backendMessage) {
      case 'Child not found':
        return ParentChildDetailsErrorCode.childNotFound;

      case 'Parent not found':
        return ParentChildDetailsErrorCode.parentNotFound;

      case 'Parent access required':
        return ParentChildDetailsErrorCode.parentAccessRequired;

      case 'Failed to delete child and related data':
        return ParentChildDetailsErrorCode.deleteChildRelatedData;

      default:
        return ParentChildDetailsErrorCode.deleteChild;
    }
  }

  String? _readBackendMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is! Map) {
      return null;
    }

    final errorMessage = responseData['error']?.toString().trim();

    if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }

    final message = responseData['message']?.toString().trim();

    if (message == null || message.isEmpty) {
      return null;
    }

    return message;
  }

  void _clearError() {
    _errorCode = null;
    _backendMessage = null;
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
