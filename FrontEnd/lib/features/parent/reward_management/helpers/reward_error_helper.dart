import 'package:dio/dio.dart';

String? readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString();
    }

    return null;
  }