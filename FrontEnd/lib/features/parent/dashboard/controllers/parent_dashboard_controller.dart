import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/parent_dashboard_data.dart';
import '../repositories/parent_dashboard_repository.dart';

enum ParentDashboardErrorCode {
  loadDashboard,
  refreshDashboard,
  deleteChild,
  childNotFound,
  parentNotFound,
  parentAccessRequired,
  deleteChildRelatedData,
}

class ParentDashboardController extends ChangeNotifier {
  final ParentDashboardRepository _repository;

  ParentDashboardController(this._repository);

  ParentDashboardData? _data;

  bool _isLoading = false;
  bool _isRefreshing = false;

  String? _deletingChildId;

  ParentDashboardErrorCode? _errorCode;
  String? _backendMessage;

  ParentDashboardData? get data => _data;

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  String? get deletingChildId => _deletingChildId;

  ParentDashboardErrorCode? get errorCode => _errorCode;

  String? get backendMessage => _backendMessage;

  bool get hasData => _data != null;

  bool isDeletingChild(String childId) {
    return _deletingChildId == childId;
  }

  Future<void> loadDashboard() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _data = await _repository.getDashboardData();
    } on DioException catch (error) {
      _backendMessage = _readBackendMessage(error);
      _errorCode = ParentDashboardErrorCode.loadDashboard;
    } catch (error) {
      _errorCode = ParentDashboardErrorCode.loadDashboard;

      debugPrint('Loading parent dashboard failed: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    _clearError();
    notifyListeners();

    try {
      _data = await _repository.getDashboardData();
    } on DioException catch (error) {
      _backendMessage = _readBackendMessage(error);
      _errorCode = ParentDashboardErrorCode.refreshDashboard;
    } catch (error) {
      _errorCode = ParentDashboardErrorCode.refreshDashboard;

      debugPrint('Refreshing parent dashboard failed: $error');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> deleteChild(String childId) async {
    if (_deletingChildId != null) {
      return false;
    }

    _deletingChildId = childId;
    _clearError();
    notifyListeners();

    try {
      await _repository.deleteChild(childId);

      final currentData = _data;

      if (currentData != null) {
        final remainingChildren = currentData.children.where((item) {
          return item.child.id != childId;
        }).toList();

        _data = ParentDashboardData(
          user: currentData.user,
          children: remainingChildren,
        );
      }

      return true;
    } on DioException catch (error) {
      _backendMessage = _readBackendMessage(error);
      _errorCode = _mapDeleteError(_backendMessage);

      return false;
    } catch (error) {
      _errorCode = ParentDashboardErrorCode.deleteChild;

      debugPrint('Deleting child failed: $error');

      return false;
    } finally {
      _deletingChildId = null;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorCode == null && _backendMessage == null) {
      return;
    }

    _clearError();
    notifyListeners();
  }

  void _clearError() {
    _errorCode = null;
    _backendMessage = null;
  }

  ParentDashboardErrorCode _mapDeleteError(String? backendMessage) {
    switch (backendMessage) {
      case 'Child not found':
        return ParentDashboardErrorCode.childNotFound;

      case 'Parent not found':
        return ParentDashboardErrorCode.parentNotFound;

      case 'Parent access required':
        return ParentDashboardErrorCode.parentAccessRequired;

      case 'Failed to delete child and related data':
        return ParentDashboardErrorCode.deleteChildRelatedData;

      default:
        return ParentDashboardErrorCode.deleteChild;
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
