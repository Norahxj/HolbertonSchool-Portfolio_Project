import '../../../../models/user_model.dart';
import '../../../../services/user_api_service.dart';

class ProfileRepository {
  final UserApiService _userApiService;

  ProfileRepository({
    UserApiService? userApiService,
  }) : _userApiService = userApiService ?? UserApiService();

  Future<UserModel> getCurrentUser() {
    return _userApiService.getCurrentUser();
  }

  Future<UserModel> updateCurrentUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    return _userApiService.updateCurrentUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
  }
}