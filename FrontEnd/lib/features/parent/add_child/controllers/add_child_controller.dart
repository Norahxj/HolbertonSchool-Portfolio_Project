import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../services/child_api_service.dart';

class AddChildController extends ChangeNotifier {
  final ChildApiService _childApiService;

  AddChildController({required this.isArabic, ChildApiService? childApiService})
    : _childApiService = childApiService ?? ChildApiService();

  final bool isArabic;

  int _selectedAvatarIndex = 0;

  int get selectedAvatarIndex => _selectedAvatarIndex;

  DateTime? _selectedBirthDate;

  DateTime? get selectedBirthDate => _selectedBirthDate;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  String? _nameError;

  String? get nameError => _nameError;

  String? _birthDateError;

  String? get birthDateError => _birthDateError;

  String? _phoneError;

  String? get phoneError => _phoneError;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  String tr(String arabic, String english) {
    return isArabic ? arabic : english;
  }

  void selectAvatar(int avatarIndex) {
    if (_selectedAvatarIndex == avatarIndex) {
      return;
    }

    _selectedAvatarIndex = avatarIndex;
    notifyListeners();
  }

  void selectBirthDate(DateTime date) {
    _selectedBirthDate = date;
    _birthDateError = null;
    notifyListeners();
  }

  DateTime get earliestBirthDate {
    final now = DateTime.now();

    return DateTime(now.year - 18, now.month, now.day);
  }

  DateTime get latestBirthDate {
    final now = DateTime.now();

    return DateTime(now.year - 6, now.month, now.day);
  }

  DateTime get initialBirthDate {
    final now = DateTime.now();

    var initialDate =
        _selectedBirthDate ?? DateTime(now.year - 7, now.month, now.day);

    if (initialDate.isBefore(earliestBirthDate)) {
      initialDate = earliestBirthDate;
    }

    if (initialDate.isAfter(latestBirthDate)) {
      initialDate = latestBirthDate;
    }

    return initialDate;
  }

  String get birthDateLabel {
    final date = _selectedBirthDate;

    if (date == null) {
      return tr('تاريخ الميلاد', 'Date of birth');
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  bool validateFields({required String name, required String phone}) {
    _nameError = null;
    _phoneError = null;
    _birthDateError = null;
    _errorMessage = null;

    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();

    if (trimmedName.isEmpty) {
      _nameError = tr('اسم الطفل مطلوب', 'Child name is required');

      notifyListeners();
      return false;
    }

    if (trimmedName.length < 2) {
      _nameError = tr(
        'يجب أن يتكون اسم الطفل من حرفين على الأقل',
        'Child name must contain at least 2 characters',
      );

      notifyListeners();
      return false;
    }

    final validName = RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$');

    if (!validName.hasMatch(trimmedName)) {
      _nameError = tr(
        'يجب أن يحتوي الاسم على حروف عربية أو إنجليزية فقط',
        'The name must contain letters only',
      );

      notifyListeners();
      return false;
    }

    if (_selectedBirthDate == null) {
      _birthDateError = tr('تاريخ الميلاد مطلوب', 'Date of birth is required');

      notifyListeners();
      return false;
    }

    if (trimmedPhone.isNotEmpty &&
        !RegExp(r'^05\d{8}$').hasMatch(trimmedPhone)) {
      _phoneError = tr(
        'أدخل رقم جوال سعودي صحيح يبدأ بـ 05',
        'Enter a valid Saudi phone number starting with 05',
      );

      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> saveChild({required String name, required String phone}) async {
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();

    final isValid = validateFields(name: trimmedName, phone: trimmedPhone);

    if (!isValid || _isSaving) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _childApiService.addChild(
        name: trimmedName,
        birthDate: _formatBirthDate(_selectedBirthDate!),
        avatarIndex: _selectedAvatarIndex,
        phone: trimmedPhone.isEmpty ? null : trimmedPhone,
      );

      return true;
    } on DioException catch (error) {
      debugPrint(
        'Add child failed: '
        '${error.response?.statusCode} '
        '${error.response?.data}',
      );

      _readValidationErrors(error);

      if (_nameError == null &&
          _phoneError == null &&
          _birthDateError == null) {
        _errorMessage = _readAddChildErrorMessage(error);
      }

      return false;
    } catch (error) {
      debugPrint('Unexpected add child error: $error');

      _errorMessage = tr(
        'حدث خطأ غير متوقع أثناء إضافة الطفل.',
        'An unexpected error occurred while adding the child.',
      );

      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _readValidationErrors(DioException error) {
    final responseData = error.response?.data;

    if (responseData is! Map) {
      return;
    }

    final errors = responseData['errors'];

    if (errors is! Map) {
      return;
    }

    _nameError = _firstError(errors['name']);

    _phoneError = _firstError(errors['phone']);

    _birthDateError = _firstError(errors['birth_date']);
  }

  String _readAddChildErrorMessage(DioException error) {
    final responseData = error.response?.data;

    var message = tr(
      'تعذر إضافة الطفل. حاولي مرة أخرى.',
      'Could not add the child. Please try again.',
    );

    if (responseData is! Map) {
      return message;
    }

    final backendMessage = responseData['error'] ?? responseData['message'];

    if (backendMessage is! String || backendMessage.trim().isEmpty) {
      return message;
    }

    switch (backendMessage) {
      case 'Phone number already used':
        return tr(
          'رقم الجوال مستخدم بالفعل.',
          'This phone number is already in use.',
        );

      case 'Parent is not assigned to a family':
        return tr(
          'حساب ولي الأمر غير مرتبط بأسرة.',
          'The parent account is not linked to a family.',
        );

      case 'Parent access required':
        return tr(
          'إضافة الأطفال متاحة لولي الأمر فقط.',
          'Only parents can add children.',
        );

      case 'Parent not found':
        return tr(
          'تعذّر العثور على حساب ولي الأمر.',
          'The parent account could not be found.',
        );

      case 'Could not create child':
        return tr(
          'تعذّر إنشاء حساب الطفل.',
          'Could not create the child account.',
        );

      default:
        return backendMessage;
    }
  }

  String _formatBirthDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String? _firstError(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }
}
