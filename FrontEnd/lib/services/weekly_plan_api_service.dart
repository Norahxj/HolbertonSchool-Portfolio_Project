import 'package:dio/dio.dart';

import '../core/network/dio_factory.dart';
import '../features/parent/weekly_plan/models/weekly_plan_models.dart';

class WeeklyPlanApiService {
  final Dio _dio;

  WeeklyPlanApiService({
    Dio? dio,
  }) : _dio = dio ?? DioFactory.getLongRunningDio();

  Future<WeeklyPlanResult> generateWeeklyPlan(
    String childId,
  ) async {
    final response = await _dio.post<dynamic>(
      '/weekly-plan/children/$childId',
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
    final response = await _dio.post<dynamic>(
      '/weekly-plan/$proposalId/approve',
      data: {
        'language': languageCode,
      },
    );

    return WeeklyPlanApprovalResult.fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  }

  Future<void> rejectWeeklyPlan({
    required String proposalId,
  }) async {
    await _dio.post<dynamic>(
      '/weekly-plan/$proposalId/reject',
    );
  }
}