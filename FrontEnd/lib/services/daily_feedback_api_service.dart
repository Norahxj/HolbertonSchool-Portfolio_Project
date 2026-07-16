import '../core/network/api_service.dart';
import '../core/network/dio_factory.dart';
import '../models/daily_feedback_model.dart';

class DailyFeedbackApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  /// Parent: create a daily feedback entry for a child.
  /// [childId] – the child's ID.
  /// [mood] – one of the MOOD_VALUES (e.g. 'HAPPY').
  Future<DailyFeedbackModel> createFeedback({
    required String childId,
    required String mood,
  }) async {
    final response = await _apiService.createDailyFeedback({
      'child_id': childId,
      'mood': mood,
    });
    return DailyFeedbackModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Parent: get all feedback entries for a specific child.
  Future<List<DailyFeedbackModel>> getFeedbackForChild(String childId) async {
    final response = await _apiService.getDailyFeedbackForChild(childId);
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map(
          (json) =>
              DailyFeedbackModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Parent: get today's feedback for a specific child.
  Future<DailyFeedbackModel?> getTodayFeedback(String childId) async {
    try {
      final response = await _apiService.getTodayFeedback(childId);
      if (response.data == null) return null;
      return DailyFeedbackModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  /// Parent: update an existing feedback entry.
  Future<DailyFeedbackModel> updateFeedback({
    required String feedbackId,
    required String mood,
  }) async {
    final response = await _apiService.updateDailyFeedback(
      feedbackId,
      {'mood': mood},
    );
    return DailyFeedbackModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Child: get my own feedback history.
  Future<List<DailyFeedbackModel>> getMyFeedback() async {
    final response = await _apiService.getMyDailyFeedback();
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map(
          (json) =>
              DailyFeedbackModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}
