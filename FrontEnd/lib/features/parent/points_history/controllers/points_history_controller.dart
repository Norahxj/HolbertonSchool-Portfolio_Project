import 'package:flutter/material.dart';

import '../../../../models/points_history_model.dart';
import '../repositories/points_history_repository.dart';

class PointsHistoryController extends ChangeNotifier {
  final PointsHistoryRepository _repository;

  PointsHistoryController({
    required this.childId,
    PointsHistoryRepository? repository,
  }) : _repository = repository ?? PointsHistoryRepository();

  final String childId;

  final List<PointsHistoryModel> _history = [];

  List<PointsHistoryModel> get history => List.unmodifiable(_history);

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  bool _hasError = false;

  bool get hasError => _hasError;

  Future<void> loadHistory() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final loadedHistory = await _repository.getChildHistory(childId);

      _history
        ..clear()
        ..addAll(loadedHistory);
    } catch (error) {
      debugPrint('Loading points history failed: $error');

      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadHistory();
  }
}