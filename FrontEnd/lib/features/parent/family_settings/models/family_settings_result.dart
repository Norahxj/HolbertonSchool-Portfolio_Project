import 'family_settings_errors.dart';

class FamilySettingsActionResult {
  final bool isSuccess;
  final FamilySettingsErrorCode? errorCode;
  final String? backendMessage;

  const FamilySettingsActionResult._({
    required this.isSuccess,
    this.errorCode,
    this.backendMessage,
  });

  const FamilySettingsActionResult.success() : this._(isSuccess: true);

  const FamilySettingsActionResult.failure({
    required FamilySettingsErrorCode errorCode,
    String? backendMessage,
  }) : this._(
         isSuccess: false,
         errorCode: errorCode,
         backendMessage: backendMessage,
       );

  const FamilySettingsActionResult.ignored() : this._(isSuccess: false);
}
