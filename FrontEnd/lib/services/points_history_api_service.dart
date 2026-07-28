
import '../models/points_history_model.dart';
import 'package:dio/dio.dart';

import '../core/network/dio_factory.dart';

class PointsHistoryApiService {
  final Dio _dio = DioFactory.getDio();

  Future<List<PointsHistoryModel>> getChildHistory(
    String childId,
  ) async {
    final response = await _dio.get(
      '/points-history/child/$childId',
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (e) => PointsHistoryModel.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}