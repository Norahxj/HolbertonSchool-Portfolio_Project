import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../models/reward_suggestion_model.dart';
import '../../../../services/reward_api_service.dart';

enum AddRewardErrorCode { rewardNameRequired, saveReward, genericSaveReward }

class AddRewardController extends ChangeNotifier {
  final RewardApiService _rewardApiService;

  AddRewardController({
    required this.childId,
    this.suggestion,
    RewardApiService? rewardApiService,
  }) : _rewardApiService = rewardApiService ?? RewardApiService(),
       _selectedUnlockDay = suggestion?.unlockDay.clamp(0, 6).toInt() ?? 3;

  final String childId;
  final RewardSuggestionModel? suggestion;

  int _selectedUnlockDay;

  int get selectedUnlockDay => _selectedUnlockDay;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  AddRewardErrorCode? _nameError;

  AddRewardErrorCode? get nameError => _nameError;

  List<int> get weekDays => const [0, 1, 2, 3, 4, 5, 6];

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
      _nameError = AddRewardErrorCode.rewardNameRequired;

      notifyListeners();

      return const AddRewardResult(
        errorCode: AddRewardErrorCode.rewardNameRequired,
      );
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

      return AddRewardResult(
        errorCode: AddRewardErrorCode.saveReward,
        backendMessage: _readBackendMessage(error),
      );
    } catch (error) {
      debugPrint('Save reward failed: $error');

      return const AddRewardResult(
        errorCode: AddRewardErrorCode.genericSaveReward,
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
  final AddRewardErrorCode? errorCode;
  final String? backendMessage;

  const AddRewardResult({
    this.isSuccess = false,
    this.errorCode,
    this.backendMessage,
  });
}
