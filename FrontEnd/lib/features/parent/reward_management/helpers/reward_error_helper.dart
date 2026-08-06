import 'package:dio/dio.dart';

String? readBackendMessage(DioException error) {
  final data = error.response?.data;

  if (data is! Map) {
    return null;
  }

  final errorMessage = data['error']?.toString().trim();

  if (errorMessage != null && errorMessage.isNotEmpty) {
    return errorMessage;
  }

  final errors = data['errors'];

  if (errors is Map && errors.isNotEmpty) {
    final firstError = errors.values.first;

    if (firstError is List && firstError.isNotEmpty) {
      return firstError.first.toString().trim();
    }

    return firstError.toString().trim();
  }

  final message = data['message']?.toString().trim();

  if (message == null || message.isEmpty) {
    return null;
  }

  return message;
}
