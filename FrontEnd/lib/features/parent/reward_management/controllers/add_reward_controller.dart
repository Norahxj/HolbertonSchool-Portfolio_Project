import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/reward_suggestion_model.dart';
import '../helpers/reward_error_helper.dart';
import '../models/add_reward_result.dart';
import '../repositories/add_reward_repository.dart';

class AddRewardController extends ChangeNotifier {
  final AddRewardRepository _repository;

  AddRewardController({
    required this.childId,
    this.suggestion,
    AddRewardRepository? repository,
  }) : _repository = repository ?? AddRewardRepository(),
       _selectedUnlockDay = suggestion?.unlockDay.clamp(0, 6).toInt() ?? 3;

  final String childId;
  final RewardSuggestionModel? suggestion;

  int _selectedUnlockDay;

  int get selectedUnlockDay => _selectedUnlockDay;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  AddRewardErrorCode? _nameError;

  AddRewardErrorCode? get nameError => _nameError;

  List<int> get weekDays {
    return const [0, 1, 2, 3, 4, 5, 6];
  }

  void selectUnlockDay(int dayIndex) {
    if (_selectedUnlockDay == dayIndex || dayIndex < 0 || dayIndex > 6) {
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
      return const AddRewardResult.success();
    }

    final cleanRewardName = rewardName.trim();
    final cleanDescription = description.trim();

    _nameError = null;

    if (cleanRewardName.isEmpty) {
      _nameError = AddRewardErrorCode.rewardNameRequired;

      notifyListeners();

      return const AddRewardResult.failure(
        errorCode: AddRewardErrorCode.rewardNameRequired,
      );
    }

    _isSaving = true;
    notifyListeners();

    try {
      await _repository.createReward(
        childId: childId,
        rewardName: cleanRewardName,
        description: cleanDescription.isEmpty ? null : cleanDescription,
        unlockDay: _selectedUnlockDay,
      );

      return const AddRewardResult.success();
    } on DioException catch (error) {
      debugPrint(
        'Saving reward failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      return AddRewardResult.failure(
        errorCode: AddRewardErrorCode.saveReward,
        backendMessage: readBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Saving reward failed: '
        '$error\n$stackTrace',
      );

      return const AddRewardResult.failure(
        errorCode: AddRewardErrorCode.genericSaveReward,
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
