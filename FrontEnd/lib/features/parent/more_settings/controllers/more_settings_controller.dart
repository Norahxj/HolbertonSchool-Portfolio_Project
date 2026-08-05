import 'package:flutter/material.dart';

import '../../../../models/user_model.dart';
import '../../../../services/user_api_service.dart';

class MoreSettingsController extends ChangeNotifier {
  final UserApiService _userApiService;

  MoreSettingsController({UserApiService? userApiService})
    : _userApiService = userApiService ?? UserApiService();

  UserModel? _user;

  UserModel? get user => _user;

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<void> loadUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userApiService.getCurrentUser();
    } catch (_) {
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
}
