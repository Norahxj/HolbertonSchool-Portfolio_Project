import 'package:dio/dio.dart';

import '../models/weekly_plan_models.dart';
import '../../../../services/weekly_plan_api_service.dart';


class WeeklyPlanRepository {
  final WeeklyPlanApiService _weeklyPlanApiService;

  WeeklyPlanRepository({
    WeeklyPlanApiService? weeklyPlanApiService,
  }) : _weeklyPlanApiService = (
         weeklyPlanApiService
         ?? WeeklyPlanApiService()
       );


  Future<WeeklyPlanResult> generateWeeklyPlan(
    String childId,
  ) async {
    try {
      return await _weeklyPlanApiService.generateWeeklyPlan(
        childId,
      );
    } on DioException catch (error) {
      throw WeeklyPlanException(
        _readBackendMessage(
          error,
          fallback: 'Unable to generate weekly plan.',
        ),
      );
    } catch (_) {
      throw const WeeklyPlanException(
        'Unable to generate weekly plan.',
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
        _readBackendMessage(
          error,
          fallback: 'Unable to approve weekly plan.',
        ),
      );
    } catch (_) {
      throw const WeeklyPlanException(
        'Unable to approve weekly plan.',
      );
    }
  }


  String _readBackendMessage(
    DioException error, {
    required String fallback,
  }) {
    final data = error.response?.data;

    if (data is Map) {
      final message = (
        data['error']
        ?? data['message']
      );

      if (message != null) {
        return message.toString();
      }
    }

    if (error.response?.statusCode == 503) {
      return 'AI service is temporarily unavailable.';
    }

    if (error.response?.statusCode == 422) {
      return 'Unable to generate a suitable weekly plan.';
    }

    return fallback;
  }
}


class WeeklyPlanException implements Exception {
  final String message;

  const WeeklyPlanException(
    this.message,
  );

  @override
  String toString() => message;
}