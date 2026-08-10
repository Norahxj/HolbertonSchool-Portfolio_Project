import 'package:flutter/material.dart';

import '../../../../models/child_model.dart';
import '../../../../models/daily_feedback_model.dart';
import '../repositories/daily_feedback_repository.dart';

enum DailyFeedbackErrorCode {
  loadFeedback,
  saveFeedback,
}

class DailyFeedbackController extends ChangeNotifier {
  final DailyFeedbackRepository _repository;

  DailyFeedbackController({
    required this.child,
    DailyFeedbackRepository? repository,
  }) : _repository = repository ?? DailyFeedbackRepository();

  final ChildModel child;

  final List<DailyFeedbackModel> _feedbackHistory = [];

  List<DailyFeedbackModel> get feedbackHistory =>
      List.unmodifiable(_feedbackHistory);

  DailyFeedbackModel? _todayFeedback;

  DailyFeedbackModel? get todayFeedback => _todayFeedback;

  String? _selectedMood;

  String? get selectedMood => _selectedMood;

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  DailyFeedbackErrorCode? _errorCode;

  DailyFeedbackErrorCode? get errorCode => _errorCode;

  void selectMood(String mood) {
    if (_selectedMood == mood) {
      return;
    }

    _selectedMood = mood;
    notifyListeners();
  }

  Future<void> loadFeedback() async {
    _isLoading = true;
    _errorCode = null;
    notifyListeners();

    try {
      final history = await _repository.getFeedbackForChild(child.id);

      history.sort((first, second) {
        return second.feedbackDate.compareTo(first.feedbackDate);
      });

      final today = DateTime.now();

      DailyFeedbackModel? todayFeedback;

      for (final feedback in history) {
        if (_isSameDay(feedback.feedbackDate, today)) {
          todayFeedback = feedback;
          break;
        }
      }

      _feedbackHistory
        ..clear()
        ..addAll(history);

      _todayFeedback = todayFeedback;
      _selectedMood = todayFeedback?.mood;
    } catch (error) {
      debugPrint('Loading daily feedback failed: $error');

      _errorCode = DailyFeedbackErrorCode.loadFeedback;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DailyFeedbackSubmitResult> submitFeedback() async {
    final selectedMood = _selectedMood;

    if (selectedMood == null || _isSubmitting) {
      return const DailyFeedbackSubmitResult();
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      late final DailyFeedbackModel savedFeedback;

      final todayFeedback = _todayFeedback;

      if (todayFeedback != null) {
        savedFeedback = await _repository.updateFeedback(
          feedbackId: todayFeedback.id,
          mood: selectedMood,
        );
      } else {
        savedFeedback = await _repository.createFeedback(
          childId: child.id,
          mood: selectedMood,
        );
      }

      _todayFeedback = savedFeedback;
      _selectedMood = savedFeedback.mood;

      final existingIndex = _feedbackHistory.indexWhere((feedback) {
        return feedback.id == savedFeedback.id;
      });

      if (existingIndex == -1) {
        _feedbackHistory.insert(0, savedFeedback);
      } else {
        _feedbackHistory[existingIndex] = savedFeedback;
      }

      return DailyFeedbackSubmitResult(
        feedback: savedFeedback,
      );
    } catch (error) {
      debugPrint('Saving daily feedback failed: $error');

      return const DailyFeedbackSubmitResult(
        errorCode: DailyFeedbackErrorCode.saveFeedback,
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class DailyFeedbackSubmitResult {
  final DailyFeedbackModel? feedback;
  final DailyFeedbackErrorCode? errorCode;

  const DailyFeedbackSubmitResult({
    this.feedback,
    this.errorCode,
  });

  bool get isSuccess => feedback != null;
}