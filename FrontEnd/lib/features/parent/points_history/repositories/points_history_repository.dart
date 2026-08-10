import '../../../../models/points_history_model.dart';
import '../../../../services/points_history_api_service.dart';

class PointsHistoryRepository {
  final PointsHistoryApiService _apiService;

  PointsHistoryRepository({
    PointsHistoryApiService? apiService,
  }) : _apiService = apiService ?? PointsHistoryApiService();

  Future<List<PointsHistoryModel>> getChildHistory(String childId) {
    return _apiService.getChildHistory(childId);
  }
}