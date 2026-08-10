import '../../../../models/user_model.dart';
import '../../../../services/user_api_service.dart';
import '../../../auth/services/auth_api_service.dart';

class MoreSettingsRepository {
  final UserApiService _userApiService;
  final AuthApiService _authApiService;

  MoreSettingsRepository({
    UserApiService? userApiService,
    AuthApiService? authApiService,
  }) : _userApiService = userApiService ?? UserApiService(),
       _authApiService = authApiService ?? AuthApiService();

  Future<UserModel> getCurrentUser() {
    return _userApiService.getCurrentUser();
  }

  Future<void> logout() {
    return _authApiService.logout();
  }
}