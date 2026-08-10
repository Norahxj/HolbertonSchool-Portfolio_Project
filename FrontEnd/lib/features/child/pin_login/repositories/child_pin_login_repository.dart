import '../../../auth/services/auth_api_service.dart';

class ChildPinLoginRepository {
  final AuthApiService _authApiService;

  ChildPinLoginRepository({
    AuthApiService? authApiService,
  }) : _authApiService =
            authApiService ?? AuthApiService();

  Future<void> login(String accessCode) async {
    await _authApiService.childLogin(
      accessCode: accessCode,
    );
  }
}