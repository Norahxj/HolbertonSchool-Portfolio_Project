import '../../../../models/user_model.dart';
import 'profile_error_code.dart';

class ProfileSaveResult {
  final UserModel? user;
  final ProfileErrorCode? errorCode;
  final String? backendMessage;

  const ProfileSaveResult({this.user, this.errorCode, this.backendMessage});

  bool get isSuccess => user != null;
}
