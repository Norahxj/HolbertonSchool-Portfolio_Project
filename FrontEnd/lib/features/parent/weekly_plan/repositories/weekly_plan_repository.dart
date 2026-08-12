import 'package:dio/dio.dart';

import '../../../../services/weekly_plan_api_service.dart';
import '../models/weekly_plan_models.dart';

enum WeeklyPlanErrorType {
  generateFailed,
  approveFailed,
  serviceUnavailable,
  noSuitablePlan,
}

class WeeklyPlanRepository {
  final WeeklyPlanApiService _weeklyPlanApiService;

  WeeklyPlanRepository({
    WeeklyPlanApiService? weeklyPlanApiService,
  }) : _weeklyPlanApiService =
            weeklyPlanApiService ?? WeeklyPlanApiService();

  Future<WeeklyPlanResult> generateWeeklyPlan(
    String childId,
  ) async {
    try {
      return await _weeklyPlanApiService.generateWeeklyPlan(
        childId,
      );
    } on DioException catch (error) {
      throw WeeklyPlanException(
        _resolveErrorType(
          error,
          fallback: WeeklyPlanErrorType.generateFailed,
        ),
      );
    } catch (_) {
      throw const WeeklyPlanException(
        WeeklyPlanErrorType.generateFailed,
      );
    }
  }

  Future<WeeklyPlanApprovalResult> approveWeeklyPlan({
    required String proposalId,
    required String languageCode,
  }) async {
    try {
      return await _weeklyPlanApiService.approveWeeklyPlan(
        proposalId: proposalId,
        languageCode: languageCode,
      );
    } on DioException catch (error) {
      throw WeeklyPlanException(
        _resolveErrorType(
          error,
          fallback: WeeklyPlanErrorType.approveFailed,
        ),
      );
    } catch (_) {
      throw const WeeklyPlanException(
        WeeklyPlanErrorType.approveFailed,
      );
    }
  }

  WeeklyPlanErrorType _resolveErrorType(
    DioException error, {
    required WeeklyPlanErrorType fallback,
  }) {
    switch (error.response?.statusCode) {
      case 503:
        return WeeklyPlanErrorType.serviceUnavailable;

      case 422:
        return WeeklyPlanErrorType.noSuitablePlan;

      default:
        return fallback;
    }
  }
}

class WeeklyPlanException implements Exception {
  final WeeklyPlanErrorType type;

  const WeeklyPlanException(
    this.type,
  );
}