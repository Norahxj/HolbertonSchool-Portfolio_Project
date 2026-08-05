import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../models/user_model.dart';
import '../../../../services/user_api_service.dart';

class ProfileController extends ChangeNotifier {
  final UserApiService _userApiService;

  ProfileController({required this.isArabic, UserApiService? userApiService})
    : _userApiService = userApiService ?? UserApiService();

  final bool isArabic;

  UserModel? _user;

  UserModel? get user => _user;

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  String? _pageError;

  String? get pageError => _pageError;

  String tr(String arabic, String english) {
    return isArabic ? arabic : english;
  }

  Future<UserModel?> loadUser() async {
    _isLoading = true;
    _pageError = null;
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

      _pageError =
          _readBackendMessage(error) ??
          tr(
            'تعذّر تحميل بيانات الملف الشخصي.',
            'Unable to load profile data.',
          );

      return null;
    } catch (error) {
      debugPrint('Loading profile failed: $error');

      _pageError = tr(
        'تعذّر تحميل بيانات الملف الشخصي.',
        'Unable to load profile data.',
      );

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

    final validationMessage = _validateFields(
      firstName: cleanFirstName,
      lastName: cleanLastName,
      email: cleanEmail,
      phone: cleanPhone,
    );

    if (validationMessage != null) {
      return ProfileSaveResult(errorMessage: validationMessage);
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

      return ProfileSaveResult(user: updatedUser);
    } on DioException catch (error) {
      debugPrint(
        'Updating profile failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      final message =
          _readBackendMessage(error) ??
          tr('تعذّر حفظ التغييرات.', 'Unable to save changes.');

      return ProfileSaveResult(errorMessage: message);
    } catch (error) {
      debugPrint('Updating profile failed: $error');

      return ProfileSaveResult(
        errorMessage: tr(
          'حدث خطأ أثناء حفظ التغييرات.',
          'An error occurred while saving changes.',
        ),
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String guardianTypeLabel(String guardianType) {
    switch (guardianType.toUpperCase()) {
      case 'MOTHER':
        return tr('أم', 'Mother');

      case 'FATHER':
        return tr('أب', 'Father');

      default:
        return tr('ولي أمر', 'Guardian');
    }
  }

  String? _validateFields({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    if (firstName.length < 2) {
      return tr(
        'يجب أن يتكون الاسم الأول من حرفين على الأقل.',
        'First name must be at least two characters.',
      );
    }

    if (lastName.length < 2) {
      return tr(
        'يجب أن يتكون اسم العائلة من حرفين على الأقل.',
        'Last name must be at least two characters.',
      );
    }

    if (!email.contains('@')) {
      return tr(
        'يرجى إدخال بريد إلكتروني صحيح.',
        'Please enter a valid email address.',
      );
    }

    if (phone.isEmpty) {
      return tr('يرجى إدخال رقم الجوال.', 'Please enter a phone number.');
    }

    return null;
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is! Map) {
      return null;
    }

    final errorMessage = data['error']?.toString();

    if (errorMessage == 'Email already registered') {
      return tr('البريد الإلكتروني مستخدم بالفعل.', 'Email is already in use.');
    }

    if (errorMessage == 'Phone number already used') {
      return tr('رقم الجوال مستخدم بالفعل.', 'Phone number is already in use.');
    }

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

class ProfileSaveResult {
  final UserModel? user;
  final String? errorMessage;

  const ProfileSaveResult({this.user, this.errorMessage});

  bool get isSuccess => user != null;
}
