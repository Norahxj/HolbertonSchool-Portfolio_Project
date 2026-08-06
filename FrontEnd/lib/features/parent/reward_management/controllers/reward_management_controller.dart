import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../models/child_model.dart';
import '../../../../models/reward_model.dart';
import '../../../../models/reward_suggestion_model.dart';
import '../../../../services/reward_api_service.dart';
import '../../services/child_api_service.dart';
import '../helpers/reward_error_helper.dart';

enum RewardManagementErrorCode {
  loadChildren,
  loadRewards,
  loadSuggestions,
  deleteNotAllowed,
  deleteClaimedReward,
  deleteReward,
}

class RewardManagementController extends ChangeNotifier {
  final ChildApiService _childApiService;
  final RewardApiService _rewardApiService;

  RewardManagementController({
    required String languageCode,
    ChildApiService? childApiService,
    RewardApiService? rewardApiService,
  }) : _languageCode = languageCode,
       _childApiService = childApiService ?? ChildApiService(),
       _rewardApiService = rewardApiService ?? RewardApiService();

  String _languageCode;

  String get languageCode => _languageCode;

  final List<ChildModel> _children = [];
  final List<RewardModel> _currentRewards = [];
  final List<RewardSuggestionModel> _rewardSuggestions = [];

  final Set<String> _deletingRewardIds = {};

  List<ChildModel> get children => List.unmodifiable(_children);

  List<RewardModel> get currentRewards => List.unmodifiable(_currentRewards);

  List<RewardSuggestionModel> get rewardSuggestions =>
      List.unmodifiable(_rewardSuggestions);

  String? _selectedChildId;

  String? get selectedChildId => _selectedChildId;

  bool _isLoadingChildren = true;
  bool _isLoadingRewards = false;
  bool _isLoadingSuggestions = false;

  bool get isLoadingChildren => _isLoadingChildren;

  bool get isLoadingRewards => _isLoadingRewards;

  bool get isLoadingSuggestions => _isLoadingSuggestions;

  RewardManagementErrorCode? _childrenError;

  RewardManagementErrorCode? get childrenError => _childrenError;

  String? _childrenBackendMessage;

  String? get childrenBackendMessage => _childrenBackendMessage;

  RewardManagementErrorCode? _rewardsError;

  RewardManagementErrorCode? get rewardsError => _rewardsError;

  String? _rewardsBackendMessage;

  String? get rewardsBackendMessage => _rewardsBackendMessage;

  RewardManagementErrorCode? _suggestionsError;

  RewardManagementErrorCode? get suggestionsError => _suggestionsError;

  String? _suggestionsBackendMessage;

  String? get suggestionsBackendMessage => _suggestionsBackendMessage;

  bool isDeletingReward(String rewardId) {
    return _deletingRewardIds.contains(rewardId);
  }

  Future<void> initialize() async {
    await Future.wait([loadChildren(), loadRewardSuggestions()]);
  }

  Future<void> updateLanguage(String languageCode) async {
    if (_languageCode == languageCode) {
      return;
    }

    _languageCode = languageCode;

    _rewardSuggestions.clear();
    _suggestionsError = null;
    _suggestionsBackendMessage = null;

    notifyListeners();

    await loadRewardSuggestions();
  }

  Future<void> loadChildren() async {
    _isLoadingChildren = true;
    _childrenError = null;
    _childrenBackendMessage = null;

    notifyListeners();

    try {
      final data = await _childApiService.getChildren();

      _children
        ..clear()
        ..addAll(data);

      if (_children.isEmpty) {
        _selectedChildId = null;
        _currentRewards.clear();
      } else {
        final selectedChildStillExists = _children.any(
          (child) => child.id == _selectedChildId,
        );

        if (_selectedChildId == null || !selectedChildStillExists) {
          _selectedChildId = _children.first.id;
        }
      }

      _isLoadingChildren = false;
      notifyListeners();

      if (_selectedChildId != null) {
        await loadCurrentRewards();
      }
    } on DioException catch (error) {
      _childrenError = RewardManagementErrorCode.loadChildren;

      _childrenBackendMessage = readBackendMessage(error);

      debugPrint(
        'Loading children failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      _isLoadingChildren = false;
      notifyListeners();
    } catch (error) {
      _childrenError = RewardManagementErrorCode.loadChildren;

      _childrenBackendMessage = null;

      debugPrint('Loading children failed: $error');

      _isLoadingChildren = false;
      notifyListeners();
    }
  }

  Future<void> selectChild(String childId) async {
    if (_selectedChildId == childId) {
      return;
    }

    _selectedChildId = childId;

    _currentRewards.clear();
    _rewardsError = null;
    _rewardsBackendMessage = null;

    notifyListeners();

    await loadCurrentRewards();
  }

  Future<void> loadCurrentRewards() async {
    final childId = _selectedChildId;

    if (childId == null) {
      return;
    }

    _isLoadingRewards = true;
    _rewardsError = null;
    _rewardsBackendMessage = null;

    notifyListeners();

    try {
      final rewards = await _rewardApiService.getRewardsForChild(childId);

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
    } catch (error) {
      if (_selectedChildId != childId) {
        return;
      }

      _rewardsError = RewardManagementErrorCode.loadRewards;

      _rewardsBackendMessage = null;

      debugPrint('Loading rewards failed: $error');
    } finally {
      if (_selectedChildId == childId) {
        _isLoadingRewards = false;
        notifyListeners();
      }
    }
  }

  Future<RewardDeleteResult> deleteReward(RewardModel reward) async {
    if (_deletingRewardIds.contains(reward.id)) {
      return const RewardDeleteResult();
    }

    final rewardIndex = _currentRewards.indexWhere(
      (item) => item.id == reward.id,
    );

    _deletingRewardIds.add(reward.id);

    _currentRewards.removeWhere((item) => item.id == reward.id);

    notifyListeners();

    try {
      await _rewardApiService.deleteReward(reward.id);

      return const RewardDeleteResult(isSuccess: true);
    } on DioException catch (error) {
      _restoreReward(reward: reward, originalIndex: rewardIndex);

      final statusCode = error.response?.statusCode;

      final backendMessage = readBackendMessage(error);

      if (statusCode == 404) {
        return const RewardDeleteResult(
          errorCode: RewardManagementErrorCode.deleteNotAllowed,
        );
      }

      if (backendMessage?.toLowerCase().contains('claimed') == true) {
        return const RewardDeleteResult(
          errorCode: RewardManagementErrorCode.deleteClaimedReward,
        );
      }

      return RewardDeleteResult(
        errorCode: RewardManagementErrorCode.deleteReward,
        backendMessage: backendMessage,
      );
    } catch (error) {
      _restoreReward(reward: reward, originalIndex: rewardIndex);

      debugPrint('Deleting reward failed: $error');

      return const RewardDeleteResult(
        errorCode: RewardManagementErrorCode.deleteReward,
      );
    } finally {
      _deletingRewardIds.remove(reward.id);
      notifyListeners();
    }
  }

  Future<void> loadRewardSuggestions() async {
    _isLoadingSuggestions = true;
    _suggestionsError = null;
    _suggestionsBackendMessage = null;

    notifyListeners();

    try {
      final suggestions = await _rewardApiService.getRewardSuggestions(
        lang: _languageCode,
        count: 5,
      );

      _rewardSuggestions
        ..clear()
        ..addAll(suggestions);
    } on DioException catch (error) {
      _suggestionsError = RewardManagementErrorCode.loadSuggestions;

      _suggestionsBackendMessage = readBackendMessage(error);

      debugPrint(
        'Loading reward suggestions failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error) {
      _suggestionsError = RewardManagementErrorCode.loadSuggestions;

      _suggestionsBackendMessage = null;

      debugPrint(
        'Loading reward suggestions failed: '
        '$error',
      );
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
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
}

class RewardDeleteResult {
  final bool isSuccess;
  final RewardManagementErrorCode? errorCode;
  final String? backendMessage;

  const RewardDeleteResult({
    this.isSuccess = false,
    this.errorCode,
    this.backendMessage,
  });
}
