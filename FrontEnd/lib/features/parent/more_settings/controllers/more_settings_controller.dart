import 'package:flutter/foundation.dart';

import '../../../../models/user_model.dart';
import '../../../../services/user_api_service.dart';
import '../../../auth/services/auth_api_service.dart';
import '../models/more_settings_error_code.dart';

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

  bool _isLoadRequestRunning = false;

  MoreSettingsErrorCode? _errorCode;

  MoreSettingsErrorCode? get errorCode => _errorCode;

  Future<void> loadUser({bool showLoading = true}) async {
    if (_isLoadRequestRunning) {
      return;
    }

    _isLoadRequestRunning = true;

    if (showLoading) {
      _isLoading = true;
    }

    _errorCode = null;
    notifyListeners();

    try {
      _user = await _userApiService.getCurrentUser();
    } catch (error, stackTrace) {
      debugPrint(
        'Loading current user failed: '
        '$error\n$stackTrace',
      );

      _errorCode = MoreSettingsErrorCode.loadUserFailed;
    } finally {
      _isLoading = false;
      _isLoadRequestRunning = false;
      notifyListeners();
    }
  }

  Future<void> refresh() {
    return loadUser(showLoading: false);
  }

  void updateUser(UserModel user) {
    _user = user;
    _errorCode = null;
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
    } catch (error, stackTrace) {
      debugPrint(
        'Parent logout failed: '
        '$error\n$stackTrace',
      );

      return false;
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }
}
