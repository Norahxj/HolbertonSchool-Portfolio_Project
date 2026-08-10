import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/parent_dashboard_data.dart';
import '../repositories/parent_dashboard_repository.dart';

enum ParentDashboardErrorCode { loadDashboard, refreshDashboard }

class ParentDashboardController extends ChangeNotifier {
  final ParentDashboardRepository _repository;

  ParentDashboardController({ParentDashboardRepository? repository})
    : _repository = repository ?? ParentDashboardRepository();

  ParentDashboardData? _data;

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isDisposed = false;

  ParentDashboardErrorCode? _errorCode;
  String? _backendMessage;

  ParentDashboardData? get data => _data;

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  ParentDashboardErrorCode? get errorCode {
    return _errorCode;
  }

  String? get backendMessage => _backendMessage;

  bool get hasData => _data != null;

  Future<void> loadDashboard() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _clearError();
    _notify();

    try {
      _data = await _repository.getDashboardData();
    } on DioException catch (error) {
      _errorCode = ParentDashboardErrorCode.loadDashboard;

      _backendMessage = _readBackendMessage(error);
    } catch (error, stackTrace) {
      _errorCode = ParentDashboardErrorCode.loadDashboard;

      debugPrint(
        'Loading parent dashboard failed: '
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
      _data = await _repository.getDashboardData();
    } on DioException catch (error) {
      _errorCode = ParentDashboardErrorCode.refreshDashboard;

      _backendMessage = _readBackendMessage(error);
    } catch (error, stackTrace) {
      _errorCode = ParentDashboardErrorCode.refreshDashboard;

      debugPrint(
        'Refreshing parent dashboard failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isRefreshing = false;
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

  void _clearError() {
    _errorCode = null;
    _backendMessage = null;
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
