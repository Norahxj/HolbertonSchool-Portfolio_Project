import 'package:flutter/material.dart';

import '../../services/family_api_service.dart';

enum FamilySettingsErrorCode {
  loadFamilyData,
  familyNameTooShort,
  invalidInvitationEmail,
  updateFamilyName,
  sendInvitation,
  acceptInvitation,
  rejectInvitation,
}

class FamilySettingsActionResult {
  final bool isSuccess;
  final FamilySettingsErrorCode? errorCode;
  final String? backendMessage;

  const FamilySettingsActionResult({
    this.isSuccess = false,
    this.errorCode,
    this.backendMessage,
  });
}

class FamilySettingsController extends ChangeNotifier {
  final FamilyApiService _familyApiService;

  FamilySettingsController({FamilyApiService? familyApiService})
    : _familyApiService = familyApiService ?? FamilyApiService();

  bool _isLoading = true;
  bool _isSavingFamilyName = false;
  bool _isSendingInvitation = false;

  FamilySettingsErrorCode? _pageErrorCode;
  String? _pageBackendMessage;

  String? _currentUserId;
  String _originalFamilyName = '';

  final Set<String> _processingInvitationIds = {};

  final List<Map<String, dynamic>> _guardians = [];
  final List<Map<String, dynamic>> _sentInvitations = [];
  final List<Map<String, dynamic>> _incomingInvitations = [];

  bool get isLoading => _isLoading;

  bool get isSavingFamilyName => _isSavingFamilyName;

  bool get isSendingInvitation => _isSendingInvitation;

  FamilySettingsErrorCode? get pageErrorCode => _pageErrorCode;

  String? get pageBackendMessage => _pageBackendMessage;

  String? get currentUserId => _currentUserId;

  String get originalFamilyName => _originalFamilyName;

  List<Map<String, dynamic>> get guardians {
    return List.unmodifiable(_guardians);
  }

  List<Map<String, dynamic>> get sentInvitations {
    return List.unmodifiable(_sentInvitations);
  }

  List<Map<String, dynamic>> get incomingInvitations {
    return List.unmodifiable(_incomingInvitations);
  }

  bool isProcessingInvitation(String invitationId) {
    return _processingInvitationIds.contains(invitationId);
  }

  Future<void> loadFamilyData({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
    }

    _clearPageError();
    notifyListeners();

    try {
      final results = await Future.wait([
        _familyApiService.getFamilyDetails(),
        _familyApiService.getIncomingInvitations(),
      ]);

      final familyData = Map<String, dynamic>.from(results[0] as Map);

      final loadedIncomingInvitations = (results[1] as List).map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();

      final loadedGuardians = (familyData['guardians'] as List? ?? []).map((
        item,
      ) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();

      final loadedSentInvitations =
          (familyData['pending_invitations'] as List? ?? []).map((item) {
            return Map<String, dynamic>.from(item as Map);
          }).toList();

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
    } catch (error) {
      _pageBackendMessage = _familyApiService.readErrorMessage(error);

      _pageErrorCode = FamilySettingsErrorCode.loadFamilyData;
    } finally {
      if (showLoading) {
        _isLoading = false;
      }

      notifyListeners();
    }
  }

  Future<FamilySettingsActionResult> saveFamilyName(
    String displayedName,
  ) async {
    final trimmedName = displayedName.trim();

    final name = _normalizeFamilyNameForSaving(
      displayedName: trimmedName,
      originalName: _originalFamilyName,
    );

    if (name.length < 2) {
      return const FamilySettingsActionResult(
        errorCode: FamilySettingsErrorCode.familyNameTooShort,
      );
    }

    if (_isSavingFamilyName) {
      return const FamilySettingsActionResult();
    }

    _isSavingFamilyName = true;
    notifyListeners();

    try {
      await _familyApiService.updateFamilyName(name);
      await loadFamilyData(showLoading: false);

      return const FamilySettingsActionResult(isSuccess: true);
    } catch (error) {
      return FamilySettingsActionResult(
        errorCode: FamilySettingsErrorCode.updateFamilyName,
        backendMessage: _familyApiService.readErrorMessage(error),
      );
    } finally {
      _isSavingFamilyName = false;
      notifyListeners();
    }
  }

  Future<FamilySettingsActionResult> sendInvitation(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (!_isValidEmail(normalizedEmail)) {
      return const FamilySettingsActionResult(
        errorCode: FamilySettingsErrorCode.invalidInvitationEmail,
      );
    }

    if (_isSendingInvitation) {
      return const FamilySettingsActionResult();
    }

    _isSendingInvitation = true;
    notifyListeners();

    try {
      await _familyApiService.inviteParent(normalizedEmail);

      await loadFamilyData(showLoading: false);

      return const FamilySettingsActionResult(isSuccess: true);
    } catch (error) {
      return FamilySettingsActionResult(
        errorCode: FamilySettingsErrorCode.sendInvitation,
        backendMessage: _familyApiService.readErrorMessage(error),
      );
    } finally {
      _isSendingInvitation = false;
      notifyListeners();
    }
  }

  Future<FamilySettingsActionResult> acceptInvitation(
    String invitationId,
  ) async {
    return _processInvitation(
      invitationId: invitationId,
      action: () {
        return _familyApiService.acceptInvitation(invitationId);
      },
      errorCode: FamilySettingsErrorCode.acceptInvitation,
    );
  }

  Future<FamilySettingsActionResult> rejectInvitation(
    String invitationId,
  ) async {
    return _processInvitation(
      invitationId: invitationId,
      action: () {
        return _familyApiService.rejectInvitation(invitationId);
      },
      errorCode: FamilySettingsErrorCode.rejectInvitation,
    );
  }

  void clearPageError() {
    if (_pageErrorCode == null && _pageBackendMessage == null) {
      return;
    }

    _clearPageError();
    notifyListeners();
  }

  Future<FamilySettingsActionResult> _processInvitation({
    required String invitationId,
    required Future<void> Function() action,
    required FamilySettingsErrorCode errorCode,
  }) async {
    if (invitationId.isEmpty ||
        _processingInvitationIds.contains(invitationId)) {
      return const FamilySettingsActionResult();
    }

    _processingInvitationIds.add(invitationId);
    notifyListeners();

    try {
      await action();
      await loadFamilyData(showLoading: false);

      return const FamilySettingsActionResult(isSuccess: true);
    } catch (error) {
      return FamilySettingsActionResult(
        errorCode: errorCode,
        backendMessage: _familyApiService.readErrorMessage(error),
      );
    } finally {
      _processingInvitationIds.remove(invitationId);
      notifyListeners();
    }
  }

  String _normalizeFamilyNameForSaving({
    required String displayedName,
    required String originalName,
  }) {
    final normalizedOriginal = _removeFamilyPrefixAndSuffix(originalName);

    final normalizedDisplayed = _removeFamilyPrefixAndSuffix(displayedName);

    if (normalizedDisplayed == normalizedOriginal) {
      return originalName.trim();
    }

    return normalizedDisplayed;
  }

  String _removeFamilyPrefixAndSuffix(String value) {
    var result = value.trim();

    result = result.replaceFirst(
      RegExp(r'^عائلة\s+', caseSensitive: false),
      '',
    );

    result = result.replaceFirst(
      RegExp(r'\s+family$', caseSensitive: false),
      '',
    );

    result = result.replaceFirst(RegExp(r"['’]s$", caseSensitive: false), '');

    return result.trim();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  void _clearPageError() {
    _pageErrorCode = null;
    _pageBackendMessage = null;
  }
}
