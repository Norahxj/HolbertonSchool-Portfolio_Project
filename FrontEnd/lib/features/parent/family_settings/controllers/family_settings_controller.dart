import 'package:flutter/material.dart';

import '../../services/family_api_service.dart';

class FamilySettingsController extends ChangeNotifier {
  final FamilyApiService _familyApiService;

  FamilySettingsController({
    required this._isArabic,
    FamilyApiService? familyApiService,
  }) : _familyApiService = familyApiService ?? FamilyApiService();

  bool _isArabic;

  bool get isArabic => _isArabic;

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  bool _isSavingFamilyName = false;

  bool get isSavingFamilyName => _isSavingFamilyName;

  bool _isSendingInvitation = false;

  bool get isSendingInvitation => _isSendingInvitation;

  String? _pageError;

  String? get pageError => _pageError;

  String? _currentUserId;

  String? get currentUserId => _currentUserId;

  String _originalFamilyName = '';

  String get originalFamilyName => _originalFamilyName;

  final List<Map<String, dynamic>> _guardians = [];

  List<Map<String, dynamic>> get guardians => List.unmodifiable(_guardians);

  final List<Map<String, dynamic>> _sentInvitations = [];

  List<Map<String, dynamic>> get sentInvitations =>
      List.unmodifiable(_sentInvitations);

  final List<Map<String, dynamic>> _incomingInvitations = [];

  List<Map<String, dynamic>> get incomingInvitations =>
      List.unmodifiable(_incomingInvitations);

  void updateLanguage(bool isArabic) {
    if (_isArabic == isArabic) {
      return;
    }

    _isArabic = isArabic;
    notifyListeners();
  }

  Future<String?> loadFamilyData({
  bool showLoading = true,
}) async {
  if (showLoading) {
    _isLoading = true;
  }

  _pageError = null;
  notifyListeners();

  try {
    final results = await Future.wait([
      _familyApiService.getFamilyDetails(),
      _familyApiService.getIncomingInvitations(),
    ]);

    final familyData = results[0] as Map<String, dynamic>;

    final loadedIncomingInvitations =
        results[1] as List<Map<String, dynamic>>;

    final loadedGuardians = (familyData['guardians'] as List? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    final loadedSentInvitations =
        (familyData['pending_invitations'] as List? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

    _originalFamilyName = familyData['name']?.toString() ?? '';
    _currentUserId = familyData['current_user_id']?.toString();

    _guardians
      ..clear()
      ..addAll(loadedGuardians);

    _sentInvitations
      ..clear()
      ..addAll(loadedSentInvitations);

    _incomingInvitations
      ..clear()
      ..addAll(loadedIncomingInvitations);

    if (showLoading) {
      _isLoading = false;
    }

    notifyListeners();

    return null;
  } catch (error) {
    _pageError = _familyApiService.readErrorMessage(error);

    if (showLoading) {
      _isLoading = false;
    }

    notifyListeners();

    return _pageError;
  }
}

  Future<String?> saveFamilyName(String displayedName) async {
    final trimmedName = displayedName.trim();

    final originalDisplayedName = displayFamilyName(_originalFamilyName);

    final name = trimmedName == originalDisplayedName
        ? _originalFamilyName
        : trimmedName;

    if (name.length < 2) {
      return _isArabic
          ? 'اسم العائلة يجب أن يكون حرفين على الأقل'
          : 'Family name must be at least two characters';
    }

    _isSavingFamilyName = true;
    notifyListeners();

    try {
      await _familyApiService.updateFamilyName(name);
      await loadFamilyData(showLoading: false);
      return null;
    } catch (error) {
      return _familyApiService.readErrorMessage(error);
    } finally {
      _isSavingFamilyName = false;
      notifyListeners();
    }
  }

  Future<String?> sendInvitation(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return _isArabic
          ? 'اكتبي بريدًا إلكترونيًا صحيحًا'
          : 'Enter a valid email address';
    }

    _isSendingInvitation = true;
    notifyListeners();

    try {
      await _familyApiService.inviteParent(normalizedEmail);
      await loadFamilyData(showLoading: false);

      return null;
    } catch (error) {
      return _familyApiService.readErrorMessage(error);
    } finally {
      _isSendingInvitation = false;
      notifyListeners();
    }
  }

  String displayFamilyName(String name) {
    final trimmedName = name.trim();

    if (!_isArabic) {
      return trimmedName;
    }

    final lowerCaseName = trimmedName.toLowerCase();

    if (lowerCaseName.endsWith(' family')) {
      final nameWithoutFamily = trimmedName
          .substring(0, trimmedName.length - ' family'.length)
          .trim();

      final cleanName = _removeEnglishPossessive(nameWithoutFamily);

      return 'عائلة $cleanName';
    }

    if (trimmedName.startsWith('عائلة ')) {
      final familyOwnerName = trimmedName.substring('عائلة '.length).trim();

      final cleanName = _removeEnglishPossessive(familyOwnerName);

      return 'عائلة $cleanName';
    }

    return _removeEnglishPossessive(trimmedName);
  }

  String guardianTypeLabel(String type) {
    switch (type) {
      case 'father':
        return _isArabic ? 'أب' : 'Father';
      case 'mother':
        return _isArabic ? 'أم' : 'Mother';
      case 'guardian':
        return _isArabic ? 'ولي أمر' : 'Guardian';
      default:
        return _isArabic ? 'ولي أمر' : 'Guardian';
    }
  }

  String _removeEnglishPossessive(String name) {
    return name
        .replaceFirst(RegExp(r"['’]s$", caseSensitive: false), '')
        .trim();
  }

  Future<String?> acceptInvitation(String invitationId) async {
    try {
      await _familyApiService.acceptInvitation(invitationId);
      await loadFamilyData(showLoading: false);
      return null;
    } catch (error) {
      return _familyApiService.readErrorMessage(error);
    }
  }

  Future<String?> rejectInvitation(String invitationId) async {
    try {
      await _familyApiService.rejectInvitation(invitationId);
      await loadFamilyData(showLoading: false);

      return null;
    } catch (error) {
      return _familyApiService.readErrorMessage(error);
    }
  }
}
