import '../../../../core/network/api_service.dart';
import '../../../../core/network/dio_factory.dart';
import '../features/parent/weekly_plan/models/weekly_plan_models.dart';


class WeeklyPlanApiService {
  final ApiService _apiService = ApiService(
    DioFactory.getDio(),
  );


  Future<WeeklyPlanResult> generateWeeklyPlan(
    String childId,
  ) async {
    final response = await _apiService.generateWeeklyPlan(
      childId,
    );

    return WeeklyPlanResult.fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  }


  Future<WeeklyPlanApprovalResult> approveWeeklyPlan({
    required String proposalId,
    required String languageCode,
  }) async {
    final response = await _apiService.approveWeeklyPlan(
      proposalId,
      {
        'language': languageCode,
      },
    );

    return WeeklyPlanApprovalResult.fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  }
}