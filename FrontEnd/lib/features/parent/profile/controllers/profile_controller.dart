import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/user_model.dart';
import '../models/profile_error_code.dart';
import '../models/profile_save_result.dart';
import '../repositories/profile_repository.dart';
import '../utils/profile_error_mapper.dart';
import '../utils/profile_validator.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileController({
    ProfileRepository? repository,
  }) : _repository = repository ?? ProfileRepository();

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
    if (_isLoading && _user != null) {
      return _user;
    }

    _setLoading(true);
    _clearPageError();

    try {
      final loadedUser = await _repository.getCurrentUser();

      _user = loadedUser;

      return loadedUser;
    } on DioException catch (error) {
      debugPrint(
        'Loading profile failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      _pageErrorCode = ProfileErrorCode.loadFailed;
      _pageBackendMessage =
          ProfileErrorMapper.readUnknownBackendMessage(error);

      return null;
    } catch (error, stackTrace) {
      debugPrint('Loading profile failed: $error\n$stackTrace');

      _pageErrorCode = ProfileErrorCode.loadFailed;

      return null;
    } finally {
      _setLoading(false);
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

    final validationError = ProfileValidator.validate(
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

    _setSaving(true);

    try {
      final updatedUser = await _repository.updateCurrentUser(
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
        errorCode: ProfileErrorMapper.mapSaveError(error),
        backendMessage:
            ProfileErrorMapper.readUnknownBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint('Updating profile failed: $error\n$stackTrace');

      return const ProfileSaveResult(
        errorCode: ProfileErrorCode.unexpectedSaveError,
      );
    } finally {
      _setSaving(false);
    }
  }

  void _clearPageError() {
    _pageErrorCode = null;
    _pageBackendMessage = null;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    if (_isSaving == value) {
      return;
    }

    _isSaving = value;
    notifyListeners();
  }
}