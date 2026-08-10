import 'package:dio/dio.dart';

import '../models/family_settings_errors.dart';

class FamilySettingsErrorMapper {
  const FamilySettingsErrorMapper._();

  static const Set<String> _knownMessages = {
    'Invited email does not belong to an existing user',
    'You cannot invite yourself',
    'User is already in your family',
    'This family already has this guardian type',
    'An invitation is already pending for this email',
    'Current user is not assigned to a family',
    'Family not found',
  };

  static FamilySettingsErrorCode? mapError(DioException error) {
    final backendMessage = readBackendMessage(error);

    switch (backendMessage) {
      case 'Invited email does not belong to an existing user':
        return FamilySettingsErrorCode.invitedUserNotFound;

      case 'You cannot invite yourself':
        return FamilySettingsErrorCode.cannotInviteYourself;

      case 'User is already in your family':
        return FamilySettingsErrorCode.userAlreadyInFamily;

      case 'This family already has this guardian type':
        return FamilySettingsErrorCode.guardianTypeAlreadyExists;

      case 'An invitation is already pending for this email':
        return FamilySettingsErrorCode.invitationAlreadyPending;

      case 'Current user is not assigned to a family':
      case 'Family not found':
        return FamilySettingsErrorCode.familyNotFound;
    }

    final data = error.response?.data;

    if (data is Map && data['errors'] != null) {
      return FamilySettingsErrorCode.invalidEnteredData;
    }

    return null;
  }

  static String? readUnknownMessage(DioException error) {
    final message = readBackendMessage(error);

    if (message == null ||
        message.trim().isEmpty ||
        _knownMessages.contains(message)) {
      return null;
    }

    return message.trim();
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

    final message = data['message']?.toString().trim();

    if (message == null || message.isEmpty) {
      return null;
    }

    return message;
  }
}
