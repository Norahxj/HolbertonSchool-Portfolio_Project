import '../models/family_details.dart';
import '../models/family_invitation.dart';
import '../services/family_api_service.dart';

class FamilySettingsData {
  final FamilyDetails family;
  final List<FamilyInvitation> incomingInvitations;

  const FamilySettingsData({
    required this.family,
    required this.incomingInvitations,
  });
}

class FamilySettingsRepository {
  final FamilyApiService _apiService;

  FamilySettingsRepository({FamilyApiService? apiService})
    : _apiService = apiService ?? FamilyApiService();

  Future<FamilySettingsData> getFamilySettingsData() async {
    final results = await Future.wait([
      _apiService.getFamilyDetails(),
      _apiService.getIncomingInvitations(),
    ]);

    final familyJson = Map<String, dynamic>.from(results[0] as Map);

    final incomingJson = List<Map<String, dynamic>>.from(results[1] as List);

    return FamilySettingsData(
      family: FamilyDetails.fromJson(familyJson),
      incomingInvitations: incomingJson.map((item) {
        return FamilyInvitation.fromJson(item);
      }).toList(),
    );
  }

  Future<void> updateFamilyName(String name) {
    return _apiService.updateFamilyName(name);
  }

  Future<void> sendInvitation(String email) {
    return _apiService.inviteParent(email);
  }

  Future<void> acceptInvitation(String invitationId) {
    return _apiService.acceptInvitation(invitationId);
  }

  Future<void> rejectInvitation(String invitationId) {
    return _apiService.rejectInvitation(invitationId);
  }
}
