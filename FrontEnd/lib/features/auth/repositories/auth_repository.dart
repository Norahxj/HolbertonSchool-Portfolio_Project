import '../services/auth_api_service.dart';

class AuthRepository {
  final AuthApiService _authApiService;

  AuthRepository({
    AuthApiService? authApiService,
  }) : _authApiService =
            authApiService ?? AuthApiService();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _authApiService.login(
      email: email,
      password: password,
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String guardianType,
  }) async {
    await _authApiService.register(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      password: password,
      guardianType: guardianType,
    );
  }
}