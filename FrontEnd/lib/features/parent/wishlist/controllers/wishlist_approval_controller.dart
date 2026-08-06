import 'package:flutter/foundation.dart';

import '../../../../services/wishlist_api_service.dart';
import '../models/wishlist_action_result.dart';
import '../models/wishlist_entry.dart';

class WishlistApprovalController extends ChangeNotifier {
  final WishlistApiService _wishlistApiService;

  WishlistApprovalController({WishlistApiService? wishlistApiService})
    : _wishlistApiService = wishlistApiService ?? WishlistApiService();

  final List<WishlistEntry> _pendingWishes = [];
  final List<WishlistEntry> _approvedWishes = [];
  final List<WishlistEntry> _achievedWishes = [];

  final Set<String> _processingWishIds = {};

  bool _isLoading = true;
  bool _hasError = false;
  bool _isLoadingRequestRunning = false;
  bool _isDisposed = false;

  List<WishlistEntry> get pendingWishes {
    return List.unmodifiable(_pendingWishes);
  }

  List<WishlistEntry> get approvedWishes {
    return List.unmodifiable(_approvedWishes);
  }

  List<WishlistEntry> get achievedWishes {
    return List.unmodifiable(_achievedWishes);
  }

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  bool get isEmpty {
    return _pendingWishes.isEmpty &&
        _approvedWishes.isEmpty &&
        _achievedWishes.isEmpty;
  }

  bool isWishProcessing(String wishId) {
    return _processingWishIds.contains(wishId);
  }

  Future<bool> loadWishes({bool showLoading = true}) async {
    if (_isLoadingRequestRunning) {
      return true;
    }

    _isLoadingRequestRunning = true;

    if (showLoading) {
      _isLoading = true;
    }

    _hasError = false;
    _notify();

    try {
      final wishes = await _wishlistApiService.getFamilyWishes();

      final pending = <WishlistEntry>[];
      final approved = <WishlistEntry>[];
      final achieved = <WishlistEntry>[];

      for (final wish in wishes) {
        final childName = wish.childName;
        final avatarIndex = wish.childAvatarIndex;

        if (childName == null || avatarIndex == null) {
          debugPrint(
            'Skipping wish ${wish.id}: '
            'missing child name or avatar index.',
          );
          continue;
        }

        final entry = WishlistEntry(
          wish: wish,
          childName: childName,
          avatarIndex: avatarIndex,
          approvedPoints: wish.targetPoints,
        );

        switch (wish.status.trim().toUpperCase()) {
          case 'PENDING':
            pending.add(entry);
            break;

          case 'APPROVED':
            approved.add(entry);
            break;

          case 'ACHIEVED':
            achieved.add(entry);
            break;

          default:
            debugPrint(
              'Skipping wish ${wish.id}: '
              'unsupported status ${wish.status}.',
            );
        }
      }

      _replaceWishes(pending: pending, approved: approved, achieved: achieved);

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Loading family wishes failed: '
        '$error\n$stackTrace',
      );

      if (showLoading || isEmpty) {
        _hasError = true;
      }

      return false;
    } finally {
      _isLoading = false;
      _isLoadingRequestRunning = false;
      _notify();
    }
  }

  Future<bool> refresh() {
    return loadWishes(showLoading: false);
  }

  Future<WishlistActionResult> approveWish({
    required String wishId,
    required int targetPoints,
  }) async {
    if (_processingWishIds.contains(wishId)) {
      return const WishlistActionResult.success();
    }

    _setWishProcessing(wishId, true);

    try {
      final approvedWish = await _wishlistApiService.approveWish(
        wishId,
        targetPoints,
      );

      final pendingIndex = _pendingWishes.indexWhere(
        (entry) => entry.wish.id == wishId,
      );

      if (pendingIndex != -1) {
        final approvedEntry = _pendingWishes
            .removeAt(pendingIndex)
            .copyWith(wish: approvedWish, approvedPoints: targetPoints);

        _approvedWishes.insert(0, approvedEntry);
      }

      return const WishlistActionResult.success();
    } catch (error, stackTrace) {
      debugPrint(
        'Approving wish $wishId failed: '
        '$error\n$stackTrace',
      );

      return const WishlistActionResult.failure(
        WishlistActionErrorCode.approveFailed,
      );
    } finally {
      _setWishProcessing(wishId, false);
    }
  }

  Future<WishlistActionResult> rejectWish({required String wishId}) async {
    if (_processingWishIds.contains(wishId)) {
      return const WishlistActionResult.success();
    }

    _setWishProcessing(wishId, true);

    try {
      await _wishlistApiService.rejectWish(wishId);

      _pendingWishes.removeWhere((entry) => entry.wish.id == wishId);

      return const WishlistActionResult.success();
    } catch (error, stackTrace) {
      debugPrint(
        'Rejecting wish $wishId failed: '
        '$error\n$stackTrace',
      );

      return const WishlistActionResult.failure(
        WishlistActionErrorCode.rejectFailed,
      );
    } finally {
      _setWishProcessing(wishId, false);
    }
  }

  void _replaceWishes({
    required List<WishlistEntry> pending,
    required List<WishlistEntry> approved,
    required List<WishlistEntry> achieved,
  }) {
    _pendingWishes
      ..clear()
      ..addAll(pending);

    _approvedWishes
      ..clear()
      ..addAll(approved);

    _achievedWishes
      ..clear()
      ..addAll(achieved);
  }

  void _setWishProcessing(String wishId, bool isProcessing) {
    if (isProcessing) {
      _processingWishIds.add(wishId);
    } else {
      _processingWishIds.remove(wishId);
    }

    _notify();
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
