import 'package:dio/dio.dart';

import '../core/network/dio_factory.dart';
import '../features/parent/weekly_plan/models/weekly_plan_models.dart';

class WeeklyPlanApiService {
  static const Duration _aiTimeout = Duration(
    minutes: 10,
  );

  final Dio _dio;

  WeeklyPlanApiService({
    Dio? dio,
  }) : _dio = dio ?? DioFactory.getDio();

  Future<WeeklyPlanResult> generateWeeklyPlan(
    String childId,
  ) async {
    final response = await _dio.post<dynamic>(
      '/weekly-plan/children/$childId',
      options: Options(
        receiveTimeout: _aiTimeout,
        sendTimeout: _aiTimeout,
      ),
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
      options: Options(
        receiveTimeout: _aiTimeout,
        sendTimeout: _aiTimeout,
      ),
    );

    return WeeklyPlanApprovalResult.fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  }
}