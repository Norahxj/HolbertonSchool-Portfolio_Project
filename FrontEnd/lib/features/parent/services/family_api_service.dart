import 'package:dio/dio.dart';

import '../../../core/network/dio_factory.dart';

class FamilyApiService {
  final Dio _dio = DioFactory.getDio();

  Future<Map<String, dynamic>> getFamilyDetails() async {
    final response = await _dio.get('/family/me');

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateFamilyName(String name) async {
    final response = await _dio.put(
      '/family/me',
      data: {'name': name.trim()},
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> inviteParent(String email) async {
    final response = await _dio.post(
      '/family/invite',
      data: {'email': email.trim().toLowerCase()},
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> getIncomingInvitations() async {
    final response = await _dio.get('/family/invitations');

    final data = response.data as List;

    return data
        .map((item) => Map<String, dynamic>.from(item as Map))
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

  String readErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map) {
        final backendError = data['error']?.toString();

        switch (backendError) {
          case 'Invited email does not belong to an existing user':
            return 'لا يوجد حساب ولي أمر بهذا البريد الإلكتروني';

          case 'You cannot invite yourself':
            return 'لا يمكنك دعوة حسابك نفسه';

          case 'User is already in your family':
            return 'ولي الأمر موجود بالفعل في العائلة';

          case 'This family already has this guardian type':
            return 'يوجد بالفعل ولي أمر من النوع نفسه في العائلة';

          case 'An invitation is already pending for this email':
            return 'توجد دعوة معلّقة لهذا البريد بالفعل';

          case 'Current user is not assigned to a family':
          case 'Family not found':
            return 'تعذّر العثور على بيانات العائلة';
        }

        final errors = data['errors'];

        if (errors != null) {
          return 'تأكدي من صحة البيانات المدخلة';
        }

        if (backendError != null && backendError.isNotEmpty) {
          return backendError;
        }
      }
    }

    return 'حدث خطأ، حاولي مرة أخرى';
  }
}