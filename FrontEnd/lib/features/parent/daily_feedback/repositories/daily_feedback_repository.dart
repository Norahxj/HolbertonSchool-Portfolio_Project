import '../../../../models/daily_feedback_model.dart';
import '../../../../services/daily_feedback_api_service.dart';

class DailyFeedbackRepository {
  final DailyFeedbackApiService _feedbackApiService;

  DailyFeedbackRepository({
    DailyFeedbackApiService? feedbackApiService,
  }) : _feedbackApiService =
           feedbackApiService ?? DailyFeedbackApiService();

  Future<List<DailyFeedbackModel>> getFeedbackForChild(
    String childId,
  ) {
    return _feedbackApiService.getFeedbackForChild(childId);
  }

  Future<DailyFeedbackModel> createFeedback({
    required String childId,
    required String mood,
  }) {
    return _feedbackApiService.createFeedback(
      childId: childId,
      mood: mood,
    );
  }

  Future<DailyFeedbackModel> updateFeedback({
    required String feedbackId,
    required String mood,
  }) {
    return _feedbackApiService.updateFeedback(
      feedbackId: feedbackId,
      mood: mood,
    );
  }
}