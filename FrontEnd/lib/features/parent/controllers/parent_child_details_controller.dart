import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../models/task_assignment_model.dart';
import '../models/parent_child_tasks_data.dart';
import '../repositories/parent_child_details_repository.dart';

class ParentChildDetailsController extends ChangeNotifier {
  final ParentChildDetailsRepository _repository;

  ParentChildDetailsController(this._repository);

  List<TaskAssignmentModel> _tasks = [];
  List<UpcomingTaskItem> _upcomingTasks = [];

  bool _isLoading = false;
  bool _isRefreshing = false;

  String? _errorMessage;
  String? _childId;

  List<TaskAssignmentModel> get tasks => _tasks;

  List<UpcomingTaskItem> get upcomingTasks => _upcomingTasks;

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  String? get errorMessage => _errorMessage;

  bool get hasNoTaskData => _tasks.isEmpty && _upcomingTasks.isEmpty;

  Future<void> loadTasks(String childId) async {
    if (_isLoading) return;

    _childId = childId;
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final data = await _repository.getChildTasksData(childId);

      _tasks = data.assignments;
      _upcomingTasks = data.upcomingTasks;
    } on DioException catch (error) {
      _errorMessage =
          _readBackendMessage(error) ?? 'Could not load the child tasks.';
    } catch (error) {
      _errorMessage = 'Could not load the child tasks.';

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
    _errorMessage = null;

    notifyListeners();

    try {
      final data = await _repository.getChildTasksData(childId);

      _tasks = data.assignments;
      _upcomingTasks = data.upcomingTasks;
    } on DioException catch (error) {
      _errorMessage =
          _readBackendMessage(error) ?? 'Could not refresh the child tasks.';
    } catch (error) {
      _errorMessage = 'Could not refresh the child tasks.';

      debugPrint('Refreshing child tasks failed: $error');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
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
