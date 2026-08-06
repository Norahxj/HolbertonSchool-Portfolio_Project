import 'package:flutter/material.dart';

import '../../../../models/user_model.dart';
import '../../../../services/user_api_service.dart';
import '../../../auth/services/auth_api_service.dart';

class MoreSettingsController extends ChangeNotifier {
  final UserApiService _userApiService;
  final AuthApiService _authApiService;

  MoreSettingsController({
    UserApiService? userApiService,
    AuthApiService? authApiService,
  }) : _userApiService = userApiService ?? UserApiService(),
       _authApiService = authApiService ?? AuthApiService();

  UserModel? _user;

  UserModel? get user => _user;

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  bool _isLoggingOut = false;

  bool get isLoggingOut => _isLoggingOut;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<void> loadUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userApiService.getCurrentUser();
    } catch (error) {
      debugPrint('Loading current user failed: $error');

      _errorMessage = 'Unable to load user information.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadUser();
  }

  void updateUser(UserModel user) {
    _user = user;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> logout() async {
    if (_isLoggingOut) {
      return false;
    }

    _isLoggingOut = true;
    notifyListeners();

    try {
      await _authApiService.logout();
      return true;
    } catch (error) {
      debugPrint('Parent logout failed: $error');

      return false;
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }
}
