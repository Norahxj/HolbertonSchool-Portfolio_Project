import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../models/user_model.dart';
import '../../../../services/user_api_service.dart';

enum ProfileErrorCode {
  loadFailed,
  saveFailed,
  unexpectedSaveError,
  firstNameTooShort,
  lastNameTooShort,
  invalidEmail,
  phoneRequired,
  emailAlreadyUsed,
  phoneAlreadyUsed,
}

class ProfileSaveResult {
  final UserModel? user;
  final ProfileErrorCode? errorCode;
  final String? backendMessage;

  const ProfileSaveResult({
    this.user,
    this.errorCode,
    this.backendMessage,
  });

  bool get isSuccess => user != null;
}

class ProfileController extends ChangeNotifier {
  final UserApiService _userApiService;

  ProfileController({
    UserApiService? userApiService,
  }) : _userApiService = userApiService ?? UserApiService();

  UserModel? _user;

  UserModel? get user => _user;

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  ProfileErrorCode? _pageErrorCode;

  ProfileErrorCode? get pageErrorCode => _pageErrorCode;

  String? _pageBackendMessage;

  String? get pageBackendMessage => _pageBackendMessage;

  Future<UserModel?> loadUser() async {
    _isLoading = true;
    _pageErrorCode = null;
    _pageBackendMessage = null;

    notifyListeners();

    try {
      final user = await _userApiService.getCurrentUser();

      _user = user;

      return user;
    } on DioException catch (error) {
      debugPrint(
        'Loading profile failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      _pageBackendMessage = _readUnknownBackendMessage(error);
      _pageErrorCode = ProfileErrorCode.loadFailed;

      return null;
    } catch (error) {
      debugPrint('Loading profile failed: $error');

      _pageErrorCode = ProfileErrorCode.loadFailed;

      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProfileSaveResult> saveChanges({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    if (_isSaving) {
      return const ProfileSaveResult();
    }

    final cleanFirstName = firstName.trim();
    final cleanLastName = lastName.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phone.trim();

    final validationError = _validateFields(
      firstName: cleanFirstName,
      lastName: cleanLastName,
      email: cleanEmail,
      phone: cleanPhone,
    );

    if (validationError != null) {
      return ProfileSaveResult(
        errorCode: validationError,
      );
    }

    _isSaving = true;
    notifyListeners();

    try {
      final updatedUser = await _userApiService.updateCurrentUser(
        firstName: cleanFirstName,
        lastName: cleanLastName,
        email: cleanEmail,
        phone: cleanPhone,
      );

      _user = updatedUser;

      return ProfileSaveResult(
        user: updatedUser,
      );
    } on DioException catch (error) {
      debugPrint(
        'Updating profile failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      return ProfileSaveResult(
        errorCode: _readSaveErrorCode(error),
        backendMessage: _readUnknownBackendMessage(error),
      );
    } catch (error) {
      debugPrint('Updating profile failed: $error');

      return const ProfileSaveResult(
        errorCode: ProfileErrorCode.unexpectedSaveError,
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  ProfileErrorCode? _validateFields({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    if (firstName.length < 2) {
      return ProfileErrorCode.firstNameTooShort;
    }

    if (lastName.length < 2) {
      return ProfileErrorCode.lastNameTooShort;
    }

    final validEmail = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!validEmail.hasMatch(email)) {
      return ProfileErrorCode.invalidEmail;
    }

    if (phone.isEmpty) {
      return ProfileErrorCode.phoneRequired;
    }

    return null;
  }

  ProfileErrorCode _readSaveErrorCode(DioException error) {
    final backendMessage = _readBackendMessage(error);

    switch (backendMessage) {
      case 'Email already registered':
        return ProfileErrorCode.emailAlreadyUsed;

      case 'Phone number already used':
        return ProfileErrorCode.phoneAlreadyUsed;

      default:
        return ProfileErrorCode.saveFailed;
    }
  }

  String? _readUnknownBackendMessage(DioException error) {
    final backendMessage = _readBackendMessage(error);

    const knownMessages = {
      'Email already registered',
      'Phone number already used',
    };

    if (backendMessage == null ||
        backendMessage.trim().isEmpty ||
        knownMessages.contains(backendMessage)) {
      return null;
    }

    return backendMessage;
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is! Map) {
      return null;
    }

    final errorMessage = data['error']?.toString();

    if (errorMessage != null && errorMessage.trim().isNotEmpty) {
      return errorMessage;
    }

    final errors = data['errors'];

    if (errors is Map && errors.isNotEmpty) {
      final firstError = errors.values.first;

      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }

      return firstError.toString();
    }

    return data['message']?.toString();
  }
}