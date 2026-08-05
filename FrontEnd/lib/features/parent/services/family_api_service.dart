import 'dart:ui';

import 'package:dio/dio.dart';

import '../../../core/network/dio_factory.dart';

class FamilyApiService {
  final Dio _dio = DioFactory.getDio();

  bool get isArabic => PlatformDispatcher.instance.locale.languageCode == 'ar';

  Future<Map<String, dynamic>> getFamilyDetails() async {
    final response = await _dio.get('/family/me');

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateFamilyName(String name) async {
    final response = await _dio.put('/family/me', data: {'name': name.trim()});

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

    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<void> acceptInvitation(String invitationId) async {
    await _dio.put('/family/invitations/$invitationId/accept');
  }

  Future<void> rejectInvitation(String invitationId) async {
    await _dio.put('/family/invitations/$invitationId/reject');
  }

  String readErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map) {
        final backendError = data['error']?.toString();

        switch (backendError) {
          case 'Invited email does not belong to an existing user':
            return isArabic
                ? 'لا يوجد حساب ولي أمر بهذا البريد الإلكتروني'
                : 'No parent account exists with this email address';

          case 'You cannot invite yourself':
            return isArabic
                ? 'لا يمكنك دعوة حسابك نفسه'
                : 'You cannot invite your own account';

          case 'User is already in your family':
            return isArabic
                ? 'ولي الأمر موجود بالفعل في العائلة'
                : 'This parent is already in the family';

          case 'This family already has this guardian type':
            return isArabic
                ? 'يوجد بالفعل ولي أمر من النوع نفسه في العائلة'
                : 'A parent with the same guardian type already exists in the family';

          case 'An invitation is already pending for this email':
            return isArabic
                ? 'توجد دعوة معلّقة لهذا البريد بالفعل'
                : 'An invitation is already pending for this email';

          case 'Current user is not assigned to a family':
          case 'Family not found':
            return isArabic
                ? 'تعذّر العثور على بيانات العائلة'
                : 'Unable to find the family information';
        }

        final errors = data['errors'];

        if (errors != null) {
          return isArabic
              ? 'تأكدي من صحة البيانات المدخلة'
              : 'Please check the entered information';
        }

        if (backendError != null && backendError.isNotEmpty) {
          return backendError;
        }
      }
    }

    return isArabic
        ? 'حدث خطأ، حاولي مرة أخرى'
        : 'An error occurred. Please try again';
  }
}
