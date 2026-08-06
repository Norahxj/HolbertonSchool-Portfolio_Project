import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/family_guardian.dart';
import '../models/family_invitation.dart';
import '../models/family_settings_errors.dart';
import '../models/family_settings_result.dart';
import '../repositories/family_settings_repository.dart';
import '../utils/family_name_formatter.dart';
import '../utils/family_settings_error_mapper.dart';
import '../utils/family_settings_validator.dart';

class FamilySettingsController extends ChangeNotifier {
  final FamilySettingsRepository _repository;

  FamilySettingsController({FamilySettingsRepository? repository})
    : _repository = repository ?? FamilySettingsRepository();

  final List<FamilyGuardian> _guardians = [];
  final List<FamilyInvitation> _sentInvitations = [];
  final List<FamilyInvitation> _incomingInvitations = [];

  final Set<String> _processingInvitationIds = {};

  bool _isLoading = false;
  bool _isSavingFamilyName = false;
  bool _isSendingInvitation = false;
  bool _loadRequestRunning = false;
  bool _isDisposed = false;

  FamilySettingsErrorCode? _pageErrorCode;
  String? _pageBackendMessage;

  String? _currentUserId;
  String _originalFamilyName = '';

  bool get isLoading => _isLoading;

  bool get isSavingFamilyName {
    return _isSavingFamilyName;
  }

  bool get isSendingInvitation {
    return _isSendingInvitation;
  }

  FamilySettingsErrorCode? get pageErrorCode => _pageErrorCode;

  String? get pageBackendMessage {
    return _pageBackendMessage;
  }

  String? get currentUserId {
    return _currentUserId;
  }

  String get originalFamilyName {
    return _originalFamilyName;
  }

  List<FamilyGuardian> get guardians {
    return List.unmodifiable(_guardians);
  }

  List<FamilyInvitation> get sentInvitations {
    return List.unmodifiable(_sentInvitations);
  }

  List<FamilyInvitation> get incomingInvitations {
    return List.unmodifiable(_incomingInvitations);
  }

  bool isProcessingInvitation(String invitationId) {
    return _processingInvitationIds.contains(invitationId);
  }

  Future<void> loadFamilyData({bool showLoading = true}) async {
    if (_loadRequestRunning) {
      return;
    }

    _loadRequestRunning = true;

    if (showLoading) {
      _isLoading = true;
    }

    _clearPageError();
    _notify();

    try {
      final data = await _repository.getFamilySettingsData();

      _originalFamilyName = data.family.name;

      _currentUserId = data.family.currentUserId;

      _guardians
        ..clear()
        ..addAll(data.family.guardians);

      _sentInvitations
        ..clear()
        ..addAll(data.family.sentInvitations);

      _incomingInvitations
        ..clear()
        ..addAll(data.incomingInvitations);
    } on DioException catch (error) {
      _pageErrorCode =
          FamilySettingsErrorMapper.mapError(error) ??
          FamilySettingsErrorCode.loadFamilyData;

      _pageBackendMessage = FamilySettingsErrorMapper.readUnknownMessage(error);

      debugPrint(
        'Loading family settings failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error, stackTrace) {
      _pageErrorCode = FamilySettingsErrorCode.loadFamilyData;

      debugPrint(
        'Loading family settings failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isLoading = false;
      _loadRequestRunning = false;
      _notify();
    }
  }

  Future<FamilySettingsActionResult> saveFamilyName(
    String displayedName,
  ) async {
    if (_isSavingFamilyName) {
      return const FamilySettingsActionResult.ignored();
    }

    final normalizedName = FamilyNameFormatter.normalizeForSaving(
      displayedName: displayedName,
      originalName: _originalFamilyName,
    );

    final validationError = FamilySettingsValidator.validateFamilyName(
      normalizedName,
    );

    if (validationError != null) {
      return FamilySettingsActionResult.failure(errorCode: validationError);
    }

    _isSavingFamilyName = true;
    _notify();

    try {
      await _repository.updateFamilyName(normalizedName);

      await loadFamilyData(showLoading: false);

      return const FamilySettingsActionResult.success();
    } on DioException catch (error) {
      return FamilySettingsActionResult.failure(
        errorCode:
            FamilySettingsErrorMapper.mapError(error) ??
            FamilySettingsErrorCode.updateFamilyName,
        backendMessage: FamilySettingsErrorMapper.readUnknownMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Updating family name failed: '
        '$error\n$stackTrace',
      );

      return const FamilySettingsActionResult.failure(
        errorCode: FamilySettingsErrorCode.updateFamilyName,
      );
    } finally {
      _isSavingFamilyName = false;
      _notify();
    }
  }

  Future<FamilySettingsActionResult> sendInvitation(String email) async {
    if (_isSendingInvitation) {
      return const FamilySettingsActionResult.ignored();
    }

    final normalizedEmail = email.trim().toLowerCase();

    final validationError = FamilySettingsValidator.validateInvitationEmail(
      normalizedEmail,
    );

    if (validationError != null) {
      return FamilySettingsActionResult.failure(errorCode: validationError);
    }

    _isSendingInvitation = true;
    _notify();

    try {
      await _repository.sendInvitation(normalizedEmail);

      await loadFamilyData(showLoading: false);

      return const FamilySettingsActionResult.success();
    } on DioException catch (error) {
      return FamilySettingsActionResult.failure(
        errorCode:
            FamilySettingsErrorMapper.mapError(error) ??
            FamilySettingsErrorCode.sendInvitation,
        backendMessage: FamilySettingsErrorMapper.readUnknownMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Sending invitation failed: '
        '$error\n$stackTrace',
      );

      return const FamilySettingsActionResult.failure(
        errorCode: FamilySettingsErrorCode.sendInvitation,
      );
    } finally {
      _isSendingInvitation = false;
      _notify();
    }
  }

  Future<FamilySettingsActionResult> acceptInvitation(String invitationId) {
    return _processInvitation(
      invitationId: invitationId,
      action: () {
        return _repository.acceptInvitation(invitationId);
      },
      fallbackError: FamilySettingsErrorCode.acceptInvitation,
    );
  }

  Future<FamilySettingsActionResult> rejectInvitation(String invitationId) {
    return _processInvitation(
      invitationId: invitationId,
      action: () {
        return _repository.rejectInvitation(invitationId);
      },
      fallbackError: FamilySettingsErrorCode.rejectInvitation,
    );
  }

  Future<FamilySettingsActionResult> _processInvitation({
    required String invitationId,
    required Future<void> Function() action,
    required FamilySettingsErrorCode fallbackError,
  }) async {
    if (invitationId.isEmpty ||
        _processingInvitationIds.contains(invitationId)) {
      return const FamilySettingsActionResult.ignored();
    }

    _processingInvitationIds.add(invitationId);

    _notify();

    try {
      await action();

      await loadFamilyData(showLoading: false);

      return const FamilySettingsActionResult.success();
    } on DioException catch (error) {
      return FamilySettingsActionResult.failure(
        errorCode: FamilySettingsErrorMapper.mapError(error) ?? fallbackError,
        backendMessage: FamilySettingsErrorMapper.readUnknownMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Processing invitation failed: '
        '$error\n$stackTrace',
      );

      return FamilySettingsActionResult.failure(errorCode: fallbackError);
    } finally {
      _processingInvitationIds.remove(invitationId);

      _notify();
    }
  }

  void _clearPageError() {
    _pageErrorCode = null;
    _pageBackendMessage = null;
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
