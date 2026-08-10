import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/child_model.dart';
import '../../../../models/reward_model.dart';
import '../../../../models/reward_suggestion_model.dart';
import '../helpers/reward_error_helper.dart';
import '../models/reward_management_result.dart';
import '../repositories/reward_management_repository.dart';

class RewardManagementController extends ChangeNotifier {
  final RewardManagementRepository _repository;

  RewardManagementController({RewardManagementRepository? repository})
    : _repository = repository ?? RewardManagementRepository();

  final List<ChildModel> _children = [];
  final List<RewardModel> _currentRewards = [];
  final List<RewardSuggestionModel> _rewardSuggestions = [];

  final Set<String> _deletingRewardIds = {};

  String? _selectedChildId;

  bool _isLoadingChildren = false;
  bool _isLoadingRewards = false;
  bool _isLoadingSuggestions = false;

  bool _childrenRequestRunning = false;
  bool _rewardsRequestRunning = false;

  int _suggestionsRequestVersion = 0;

  bool _isDisposed = false;

  RewardManagementErrorCode? _childrenError;
  RewardManagementErrorCode? _rewardsError;
  RewardManagementErrorCode? _suggestionsError;

  String? _childrenBackendMessage;
  String? _rewardsBackendMessage;
  String? _suggestionsBackendMessage;

  List<ChildModel> get children {
    return List.unmodifiable(_children);
  }

  List<RewardModel> get currentRewards {
    return List.unmodifiable(_currentRewards);
  }

  List<RewardSuggestionModel> get rewardSuggestions {
    return List.unmodifiable(_rewardSuggestions);
  }

  String? get selectedChildId => _selectedChildId;

  bool get isLoadingChildren => _isLoadingChildren;

  bool get isLoadingRewards => _isLoadingRewards;

  bool get isLoadingSuggestions => _isLoadingSuggestions;

  RewardManagementErrorCode? get childrenError {
    return _childrenError;
  }

  RewardManagementErrorCode? get rewardsError {
    return _rewardsError;
  }

  RewardManagementErrorCode? get suggestionsError {
    return _suggestionsError;
  }

  String? get childrenBackendMessage {
    return _childrenBackendMessage;
  }

  String? get rewardsBackendMessage {
    return _rewardsBackendMessage;
  }

  String? get suggestionsBackendMessage {
    return _suggestionsBackendMessage;
  }

  bool isDeletingReward(String rewardId) {
    return _deletingRewardIds.contains(rewardId);
  }

  Future<void> initialize({required String languageCode}) async {
    await Future.wait([
      loadChildren(),
      loadRewardSuggestions(languageCode: languageCode),
    ]);
  }

  Future<void> refresh({required String languageCode}) async {
    await Future.wait([
      loadChildren(showLoading: false),
      loadRewardSuggestions(languageCode: languageCode, showLoading: false),
    ]);
  }

  Future<void> loadChildren({bool showLoading = true}) async {
    if (_childrenRequestRunning) {
      return;
    }

    _childrenRequestRunning = true;

    if (showLoading) {
      _isLoadingChildren = true;
    }

    _childrenError = null;
    _childrenBackendMessage = null;
    _notify();

    try {
      final loadedChildren = await _repository.getChildren();

      _children
        ..clear()
        ..addAll(loadedChildren);

      if (_children.isEmpty) {
        _selectedChildId = null;
        _currentRewards.clear();
        _rewardsError = null;
        _rewardsBackendMessage = null;
      } else {
        final selectedChildStillExists = _children.any(
          (child) => child.id == _selectedChildId,
        );

        if (_selectedChildId == null || !selectedChildStillExists) {
          _selectedChildId = _children.first.id;
        }
      }
    } on DioException catch (error) {
      _childrenError = RewardManagementErrorCode.loadChildren;

      _childrenBackendMessage = readBackendMessage(error);

      debugPrint(
        'Loading children failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error, stackTrace) {
      _childrenError = RewardManagementErrorCode.loadChildren;

      debugPrint(
        'Loading children failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isLoadingChildren = false;
      _childrenRequestRunning = false;
      _notify();
    }

    if (_childrenError == null && _selectedChildId != null) {
      await loadCurrentRewards();
    }
  }

  Future<void> selectChild(String childId) async {
    if (_selectedChildId == childId ||
        !_children.any((child) => child.id == childId)) {
      return;
    }

    _selectedChildId = childId;

    _currentRewards.clear();
    _rewardsError = null;
    _rewardsBackendMessage = null;

    _notify();

    await loadCurrentRewards();
  }

  Future<void> loadCurrentRewards() async {
    final childId = _selectedChildId;

    if (childId == null || _rewardsRequestRunning) {
      return;
    }

    _rewardsRequestRunning = true;
    _isLoadingRewards = true;
    _rewardsError = null;
    _rewardsBackendMessage = null;
    _notify();

    try {
      final rewards = await _repository.getRewardsForChild(childId);

      if (_selectedChildId != childId) {
        return;
      }

      _currentRewards
        ..clear()
        ..addAll(rewards);
    } on DioException catch (error) {
      if (_selectedChildId != childId) {
        return;
      }

      _rewardsError = RewardManagementErrorCode.loadRewards;

      _rewardsBackendMessage = readBackendMessage(error);

      debugPrint(
        'Loading rewards failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error, stackTrace) {
      if (_selectedChildId != childId) {
        return;
      }

      _rewardsError = RewardManagementErrorCode.loadRewards;

      debugPrint(
        'Loading rewards failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _rewardsRequestRunning = false;

      if (_selectedChildId == childId) {
        _isLoadingRewards = false;
        _notify();
      }
    }
  }

  Future<void> loadRewardSuggestions({
    required String languageCode,
    bool showLoading = true,
  }) async {
    final requestVersion = ++_suggestionsRequestVersion;

    if (showLoading) {
      _isLoadingSuggestions = true;
    }

    _suggestionsError = null;
    _suggestionsBackendMessage = null;
    _notify();

    try {
      final suggestions = await _repository.getRewardSuggestions(
        languageCode: languageCode,
      );

      if (requestVersion != _suggestionsRequestVersion) {
        return;
      }

      _rewardSuggestions
        ..clear()
        ..addAll(suggestions);
    } on DioException catch (error) {
      if (requestVersion != _suggestionsRequestVersion) {
        return;
      }

      _suggestionsError = RewardManagementErrorCode.loadSuggestions;

      _suggestionsBackendMessage = readBackendMessage(error);

      debugPrint(
        'Loading reward suggestions failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error, stackTrace) {
      if (requestVersion != _suggestionsRequestVersion) {
        return;
      }

      _suggestionsError = RewardManagementErrorCode.loadSuggestions;

      debugPrint(
        'Loading reward suggestions failed: '
        '$error\n$stackTrace',
      );
    } finally {
      if (requestVersion == _suggestionsRequestVersion) {
        _isLoadingSuggestions = false;
        _notify();
      }
    }
  }

  Future<RewardDeleteResult> deleteReward(RewardModel reward) async {
    if (_deletingRewardIds.contains(reward.id)) {
      return const RewardDeleteResult.success();
    }

    final originalIndex = _currentRewards.indexWhere(
      (item) => item.id == reward.id,
    );

    _deletingRewardIds.add(reward.id);

    _currentRewards.removeWhere((item) => item.id == reward.id);

    _notify();

    try {
      await _repository.deleteReward(reward.id);

      return const RewardDeleteResult.success();
    } on DioException catch (error) {
      _restoreReward(reward: reward, originalIndex: originalIndex);

      final statusCode = error.response?.statusCode;

      final backendMessage = readBackendMessage(error);

      if (statusCode == 404) {
        return const RewardDeleteResult.failure(
          errorCode: RewardManagementErrorCode.deleteNotAllowed,
        );
      }

      if (backendMessage?.toLowerCase().contains('claimed') == true) {
        return const RewardDeleteResult.failure(
          errorCode: RewardManagementErrorCode.deleteClaimedReward,
        );
      }

      return RewardDeleteResult.failure(
        errorCode: RewardManagementErrorCode.deleteReward,
        backendMessage: backendMessage,
      );
    } catch (error, stackTrace) {
      _restoreReward(reward: reward, originalIndex: originalIndex);

      debugPrint(
        'Deleting reward failed: '
        '$error\n$stackTrace',
      );

      return const RewardDeleteResult.failure(
        errorCode: RewardManagementErrorCode.deleteReward,
      );
    } finally {
      _deletingRewardIds.remove(reward.id);
      _notify();
    }
  }

  void _restoreReward({
    required RewardModel reward,
    required int originalIndex,
  }) {
    final rewardAlreadyRestored = _currentRewards.any(
      (item) => item.id == reward.id,
    );

    if (rewardAlreadyRestored) {
      return;
    }

    final safeIndex = originalIndex.clamp(0, _currentRewards.length).toInt();

    _currentRewards.insert(safeIndex, reward);
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _suggestionsRequestVersion++;
    super.dispose();
  }
}
