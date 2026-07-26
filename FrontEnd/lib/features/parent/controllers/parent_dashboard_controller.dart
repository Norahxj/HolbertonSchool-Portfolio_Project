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

  String? _errorMessage;

  ParentDashboardData? get data => _data;

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  String? get errorMessage => _errorMessage;

  bool get hasData => _data != null;

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

  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    notifyListeners();
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
