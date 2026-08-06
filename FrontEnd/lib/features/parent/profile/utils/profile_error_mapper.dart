import 'package:dio/dio.dart';

import '../models/profile_error_code.dart';

class ProfileErrorMapper {
  const ProfileErrorMapper._();

  static const Set<String> _knownMessages = {
    'Email already registered',
    'Phone number already used',
  };

  static ProfileErrorCode mapSaveError(DioException error) {
    final backendMessage = readBackendMessage(error);

    switch (backendMessage) {
      case 'Email already registered':
        return ProfileErrorCode.emailAlreadyUsed;

      case 'Phone number already used':
        return ProfileErrorCode.phoneAlreadyUsed;

      default:
        return ProfileErrorCode.saveFailed;
    }
  }

  static String? readUnknownBackendMessage(DioException error) {
    final backendMessage = readBackendMessage(error);

    if (backendMessage == null) {
      return null;
    }

    final cleanMessage = backendMessage.trim();

    if (cleanMessage.isEmpty || _knownMessages.contains(cleanMessage)) {
      return null;
    }

    return cleanMessage;
  }

  static String? readBackendMessage(DioException error) {
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
}
