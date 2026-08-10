import 'package:dio/dio.dart';

import '../../../../core/network/dio_factory.dart';

class FamilyApiService {
  final Dio _dio;

  FamilyApiService({Dio? dio}) : _dio = dio ?? DioFactory.getDio();

  Future<Map<String, dynamic>> getFamilyDetails() async {
    final response = await _dio.get('/family/me');

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> updateFamilyName(String name) async {
    await _dio.put('/family/me', data: {'name': name});
  }

  Future<void> inviteParent(String email) async {
    await _dio.post('/family/invite', data: {'email': email});
  }

  Future<List<Map<String, dynamic>>> getIncomingInvitations() async {
    final response = await _dio.get('/family/invitations');

    final data = response.data as List;

    return data.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  Future<void> acceptInvitation(String invitationId) {
    return _dio
        .put(
          '/family/invitations/'
          '$invitationId/accept',
        )
        .then((_) {});
  }

  Future<void> rejectInvitation(String invitationId) {
    return _dio
        .put(
          '/family/invitations/'
          '$invitationId/reject',
        )
        .then((_) {});
  }
}
