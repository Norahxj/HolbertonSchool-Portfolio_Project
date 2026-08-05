import 'package:flutter/material.dart';

import '../../../../models/child_model.dart';
import '../../../../models/daily_feedback_model.dart';
import '../../../../services/daily_feedback_api_service.dart';

class DailyFeedbackController extends ChangeNotifier {
  final DailyFeedbackApiService _feedbackService;

  DailyFeedbackController({
    required this.child,
    required this.isArabic,
    DailyFeedbackApiService? feedbackService,
  }) : _feedbackService = feedbackService ?? DailyFeedbackApiService();

  final ChildModel child;
  final bool isArabic;

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

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  String tr(String arabic, String english) {
    return isArabic ? arabic : english;
  }

  void selectMood(String mood) {
    if (_selectedMood == mood) {
      return;
    }

    _selectedMood = mood;
    notifyListeners();
  }

  Future<void> loadFeedback() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final history = await _feedbackService.getFeedbackForChild(child.id);

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

      _errorMessage = tr(
        'تعذّر تحميل سجل التقييم',
        'Unable to load feedback history',
      );
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

      if (_todayFeedback != null) {
        savedFeedback = await _feedbackService.updateFeedback(
          feedbackId: _todayFeedback!.id,
          mood: selectedMood,
        );
      } else {
        savedFeedback = await _feedbackService.createFeedback(
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

      return DailyFeedbackSubmitResult(feedback: savedFeedback);
    } catch (error) {
      debugPrint('Saving daily feedback failed: $error');

      return DailyFeedbackSubmitResult(
        errorMessage: tr(
          'تعذّر حفظ التقييم. حاول مرة أخرى.',
          'Unable to save feedback. Please try again.',
        ),
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
  final String? errorMessage;

  const DailyFeedbackSubmitResult({this.feedback, this.errorMessage});

  bool get isSuccess => feedback != null;
}
