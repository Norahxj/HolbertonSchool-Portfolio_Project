import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/parent_dashboard_data.dart';
import '../repositories/parent_dashboard_repository.dart';

class ParentDashboardController extends ChangeNotifier {
  final ParentDashboardRepository _repository;

  ParentDashboardController(this._repository);

  ParentDashboardData? _data;

  bool _isLoading = false;
  bool _isRefreshing = false;

  // Stores the ID of the child currently being deleted.
  String? _deletingChildId;

  String? _errorMessage;

  ParentDashboardData? get data => _data;

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  String? get deletingChildId => _deletingChildId;

  String? get errorMessage => _errorMessage;

  bool get hasData => _data != null;

  // Checks whether a specific child is currently being deleted.
  bool isDeletingChild(String childId) {
    return _deletingChildId == childId;
  }

  Future<void> loadDashboard() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _data = await _repository.getDashboardData();
    } on DioException catch (error) {
      _errorMessage = _readBackendMessage(error) ?? 'تعذّر تحميل لوحة التحكم.';
    } catch (error) {
      _errorMessage = 'تعذّر تحميل لوحة التحكم.';

      debugPrint('Loading parent dashboard failed: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _data = await _repository.getDashboardData();
    } on DioException catch (error) {
      _errorMessage = _readBackendMessage(error) ?? 'تعذّر تحديث لوحة التحكم.';
    } catch (error) {
      _errorMessage = 'تعذّر تحديث لوحة التحكم.';

      debugPrint('Refreshing parent dashboard failed: $error');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> deleteChild(String childId) async {
    // Prevent more than one child from being deleted at the same time.
    if (_deletingChildId != null) {
      return false;
    }

    _deletingChildId = childId;
    _errorMessage = null;

    notifyListeners();

    try {
      await _repository.deleteChild(childId);

      // Remove the deleted child immediately from the current dashboard.
      if (_data != null) {
        final remainingChildren = _data!.children.where((item) {
          return item.child.id != childId;
        }).toList();

        _data = ParentDashboardData(
          user: _data!.user,
          children: remainingChildren,
        );
      }

      return true;
    } on DioException catch (error) {
      _errorMessage = _readDeleteError(error);

      return false;
    } catch (error) {
      _errorMessage = 'تعذّر حذف الطفل. حاول مرة أخرى.';

      debugPrint('Deleting child failed: $error');

      return false;
    } finally {
      _deletingChildId = null;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    notifyListeners();
  }

  String _readDeleteError(DioException error) {
    final backendMessage = _readBackendMessage(error);

    switch (backendMessage) {
      case 'Child not found':
        return 'لم يتم العثور على الطفل، أو أنه لم يعد مرتبطًا بهذه الأسرة.';

      case 'Parent not found':
        return 'تعذّر العثور على حساب ولي الأمر.';

      case 'Parent access required':
        return 'هذا الإجراء متاح لحساب ولي الأمر فقط.';

      case 'Failed to delete child and related data':
        return 'تعذّر حذف الطفل والبيانات المرتبطة به.';

      default:
        return 'تعذّر حذف الطفل. حاول مرة أخرى.';
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
