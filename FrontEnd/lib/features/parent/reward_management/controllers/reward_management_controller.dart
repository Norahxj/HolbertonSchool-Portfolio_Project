import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../models/child_model.dart';
import '../../../../models/reward_model.dart';
import '../../../../models/reward_suggestion_model.dart';
import '../../../../services/reward_api_service.dart';
import '../../services/child_api_service.dart';
import '../helpers/reward_error_helper.dart';

class RewardManagementController extends ChangeNotifier {
  final ChildApiService _childApiService;
  final RewardApiService _rewardApiService;

  RewardManagementController({
    required this._isArabic,
    ChildApiService? childApiService,
    RewardApiService? rewardApiService,
  }) : _childApiService = childApiService ?? ChildApiService(),
       _rewardApiService = rewardApiService ?? RewardApiService();

  bool _isArabic;

  bool get isArabic => _isArabic;

  final List<ChildModel> _children = [];
  final List<RewardModel> _currentRewards = [];
  final List<RewardSuggestionModel> _rewardSuggestions = [];

  final Set<String> _deletingRewardIds = {};

  List<ChildModel> get children => List.unmodifiable(_children);

  List<RewardModel> get currentRewards => List.unmodifiable(_currentRewards);

  List<RewardSuggestionModel> get rewardSuggestions =>
      List.unmodifiable(_rewardSuggestions);

  Set<String> get deletingRewardIds => Set.unmodifiable(_deletingRewardIds);

  String? _selectedChildId;

  String? get selectedChildId => _selectedChildId;

  bool _isLoadingChildren = true;
  bool _isLoadingRewards = false;
  bool _isLoadingSuggestions = false;

  bool get isLoadingChildren => _isLoadingChildren;

  bool get isLoadingRewards => _isLoadingRewards;

  bool get isLoadingSuggestions => _isLoadingSuggestions;

  String? _childrenError;
  String? _rewardsError;
  String? _suggestionsError;

  String? get childrenError => _childrenError;

  String? get rewardsError => _rewardsError;

  String? get suggestionsError => _suggestionsError;

  bool isDeletingReward(String rewardId) {
    return _deletingRewardIds.contains(rewardId);
  }

  Future<void> initialize() async {
    await Future.wait([loadChildren(), loadRewardSuggestions()]);
  }

  Future<void> updateLanguage(bool isArabic) async {
    if (_isArabic == isArabic) {
      return;
    }

    _isArabic = isArabic;
    _rewardSuggestions.clear();
    notifyListeners();

    await loadRewardSuggestions();
  }

  Future<void> loadChildren() async {
    _isLoadingChildren = true;
    _childrenError = null;
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
      _childrenError =
          readBackendMessage(error) ??
          (_isArabic ? 'تعذّر تحميل الأطفال' : 'Failed to load children');

      _isLoadingChildren = false;
      notifyListeners();
    } catch (_) {
      _childrenError = _isArabic
          ? 'تعذّر تحميل الأطفال'
          : 'Failed to load children';

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

      _rewardsError =
          readBackendMessage(error) ??
          (_isArabic
              ? 'تعذّر تحميل مكافآت الطفل'
              : 'Failed to load child rewards');
    } finally {
      if (_selectedChildId == childId) {
        _isLoadingRewards = false;
        notifyListeners();
      }
    }
  }

  Future<String?> deleteReward(RewardModel reward) async {
    if (_deletingRewardIds.contains(reward.id)) {
      return null;
    }

    final rewardIndex = _currentRewards.indexWhere(
      (item) => item.id == reward.id,
    );

    _deletingRewardIds.add(reward.id);
    _currentRewards.removeWhere((item) => item.id == reward.id);
    notifyListeners();

    try {
      await _rewardApiService.deleteReward(reward.id);
      return null;
    } on DioException catch (error) {
      final safeIndex = rewardIndex.clamp(0, _currentRewards.length).toInt();

      final rewardAlreadyRestored = _currentRewards.any(
        (item) => item.id == reward.id,
      );

      if (!rewardAlreadyRestored) {
        _currentRewards.insert(safeIndex, reward);
      }

      final statusCode = error.response?.statusCode;
      final backendMessage = readBackendMessage(error);

      if (statusCode == 404) {
        return _isArabic
            ? 'لا يمكنك حذف هذه المكافأة؛ يمكن حذفها فقط بواسطة ولي الأمر الذي أضافها.'
            : 'You cannot delete this reward. Only the parent who added it can delete it.';
      }

      if (backendMessage?.toLowerCase().contains('claimed') == true) {
        return _isArabic
            ? 'لا يمكن حذف المكافأة بعد استلامها.'
            : 'A claimed reward cannot be deleted.';
      }

      return _isArabic
          ? 'تعذّر حذف المكافأة. حاول مرة أخرى.'
          : 'Failed to delete the reward. Please try again.';
    } catch (_) {
      final rewardAlreadyRestored = _currentRewards.any(
        (item) => item.id == reward.id,
      );

      if (!rewardAlreadyRestored) {
        final safeIndex = rewardIndex.clamp(0, _currentRewards.length).toInt();

        _currentRewards.insert(safeIndex, reward);
      }

      return _isArabic
          ? 'تعذّر حذف المكافأة. حاول مرة أخرى.'
          : 'Failed to delete the reward. Please try again.';
    } finally {
      _deletingRewardIds.remove(reward.id);
      notifyListeners();
    }
  }

  Future<void> loadRewardSuggestions() async {
    _isLoadingSuggestions = true;
    _suggestionsError = null;
    notifyListeners();

    try {
      final suggestions = await _rewardApiService.getRewardSuggestions(
        lang: _isArabic ? 'ar' : 'en',
        count: 5,
      );

      _rewardSuggestions
        ..clear()
        ..addAll(suggestions);
    } on DioException catch (error) {
      _suggestionsError =
          readBackendMessage(error) ??
          (_isArabic
              ? 'تعذّر تحميل المكافآت المقترحة'
              : 'Failed to load suggested rewards');
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }
}
