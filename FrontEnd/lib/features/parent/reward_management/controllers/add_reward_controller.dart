import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../models/reward_suggestion_model.dart';
import '../../../../services/reward_api_service.dart';

class AddRewardController extends ChangeNotifier {
  final RewardApiService _rewardApiService;

  AddRewardController({
    required this.childId,
    required this.isArabic,
    this.suggestion,
    RewardApiService? rewardApiService,
  }) : _rewardApiService = rewardApiService ?? RewardApiService(),
       _selectedUnlockDay = suggestion?.unlockDay.clamp(0, 6).toInt() ?? 3;

  final String childId;
  final bool isArabic;
  final RewardSuggestionModel? suggestion;

  int _selectedUnlockDay;

  int get selectedUnlockDay => _selectedUnlockDay;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  String? _nameError;

  String? get nameError => _nameError;

  List<String> get weekDays {
    if (isArabic) {
      return const [
        'الأحد',
        'الإثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
      ];
    }

    return const [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
  }

  String text(String arabic, String english) {
    return isArabic ? arabic : english;
  }

  void selectUnlockDay(int dayIndex) {
    if (_selectedUnlockDay == dayIndex) {
      return;
    }

    _selectedUnlockDay = dayIndex;
    notifyListeners();
  }

  Future<AddRewardResult> saveReward({
    required String rewardName,
    required String description,
  }) async {
    if (_isSaving) {
      return const AddRewardResult();
    }

    final cleanRewardName = rewardName.trim();
    final cleanDescription = description.trim();

    _nameError = null;

    if (cleanRewardName.isEmpty) {
      _nameError = text(
        'اكتب اسم المكافأة أولًا',
        'Enter the reward name first',
      );

      notifyListeners();

      return AddRewardResult(errorMessage: _nameError);
    }

    _isSaving = true;
    notifyListeners();

    try {
      await _rewardApiService.createReward(
        childId: childId,
        rewardName: cleanRewardName,
        description: cleanDescription.isEmpty ? null : cleanDescription,
        unlockDay: _selectedUnlockDay,
      );

      return const AddRewardResult(isSuccess: true);
    } on DioException catch (error) {
      debugPrint(
        'Save reward failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      final message =
          _readBackendMessage(error) ??
          text('تعذّر حفظ المكافأة', 'Could not save the reward');

      return AddRewardResult(errorMessage: message);
    } catch (error) {
      debugPrint('Save reward failed: $error');

      return AddRewardResult(
        errorMessage: text(
          'حدث خطأ أثناء حفظ المكافأة',
          'An error occurred while saving the reward',
        ),
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString();
    }

    return null;
  }
}

class AddRewardResult {
  final bool isSuccess;
  final String? errorMessage;

  const AddRewardResult({this.isSuccess = false, this.errorMessage});
}
