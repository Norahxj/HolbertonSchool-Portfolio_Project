import 'package:dio/dio.dart';

import '../../../../core/network/dio_factory.dart';

class FamilyApiService {
  FamilyApiService({Dio? dio}) : _dio = dio ?? DioFactory.getDio();

  final Dio _dio;

  Future<Map<String, dynamic>> getFamilyDetails() async {
    final response = await _dio.get('/family/me');

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateFamilyName(String name) async {
    final response = await _dio.put(
      '/family/me',
      data: {
        'name': name.trim(),
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> inviteParent(String email) async {
    final response = await _dio.post(
      '/family/invite',
      data: {
        'email': email.trim().toLowerCase(),
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> getIncomingInvitations() async {
    final response = await _dio.get('/family/invitations');

    final data = response.data as List;

    return data
        .map(
          (item) => Map<String, dynamic>.from(item as Map),
        )
        .toList();
  }

  Future<void> acceptInvitation(String invitationId) async {
    await _dio.put(
      '/family/invitations/$invitationId/accept',
    );
  }

  Future<void> rejectInvitation(String invitationId) async {
    await _dio.put(
      '/family/invitations/$invitationId/reject',
    );
  }
}