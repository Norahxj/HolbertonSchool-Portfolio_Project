import 'package:flutter/material.dart';

import '../../../../models/points_history_model.dart';
import '../../../../services/points_history_api_service.dart';

class PointsHistoryController extends ChangeNotifier {
  final PointsHistoryApiService _service;

  PointsHistoryController({
    required this.childId,
    PointsHistoryApiService? service,
  }) : _service = service ?? PointsHistoryApiService();

  final String childId;

  final List<PointsHistoryModel> _history = [];

  List<PointsHistoryModel> get history => List.unmodifiable(_history);

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedHistory = await _service.getChildHistory(childId);

      _history
        ..clear()
        ..addAll(loadedHistory);
    } catch (error) {
      debugPrint('Loading points history failed: $error');

      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadHistory();
  }
}
