import 'package:flutter/foundation.dart';

import '../../../models/wish_model.dart';
import '../../../services/wishlist_api_service.dart';

class WishlistEntry {
  final WishModel wish;
  final String childName;
  final int avatarIndex;
  final int? approvedPoints;

  const WishlistEntry({
    required this.wish,
    required this.childName,
    required this.avatarIndex,
    this.approvedPoints,
  });

  WishlistEntry copyWith({WishModel? wish, int? approvedPoints}) {
    return WishlistEntry(
      wish: wish ?? this.wish,
      childName: childName,
      avatarIndex: avatarIndex,
      approvedPoints: approvedPoints ?? this.approvedPoints,
    );
  }
}

class WishlistApprovalController extends ChangeNotifier {
  WishlistApprovalController({WishlistApiService? wishlistApiService})
    : _wishlistApiService = wishlistApiService ?? WishlistApiService();

  final WishlistApiService _wishlistApiService;

  final List<WishlistEntry> _pendingWishes = [];
  final List<WishlistEntry> _approvedWishes = [];

  bool _isLoading = true;
  bool _hasError = false;
  bool _requestRunning = false;
  bool _isDisposed = false;

  List<WishlistEntry> get pendingWishes => List.unmodifiable(_pendingWishes);

  List<WishlistEntry> get approvedWishes => List.unmodifiable(_approvedWishes);

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  bool get isEmpty => _pendingWishes.isEmpty && _approvedWishes.isEmpty;

  Future<bool> loadWishes({bool showLoading = true}) async {
    if (_requestRunning) {
      return true;
    }

    _requestRunning = true;

    if (showLoading) {
      _isLoading = true;
    }

    _hasError = false;
    _notify();

    try {
      final wishes = await _wishlistApiService.getFamilyWishes();

      final pending = <WishlistEntry>[];
      final approved = <WishlistEntry>[];

      for (final wish in wishes) {
        final childName = wish.childName;
        final avatarIndex = wish.childAvatarIndex;

        // بيانات الطفل يجب أن تأتي من endpoint العائلة.
        // نتجاوز العنصر فقط لو كانت الاستجابة ناقصة.
        if (childName == null || avatarIndex == null) {
          continue;
        }

        final wishEntry = WishlistEntry(
          wish: wish,
          childName: childName,
          avatarIndex: avatarIndex,
        );

        final status = wish.status.toUpperCase();

        if (status == 'PENDING') {
          pending.add(wishEntry);
        } else if (status == 'APPROVED') {
          approved.add(wishEntry);
        }
      }

      _pendingWishes
        ..clear()
        ..addAll(pending);

      _approvedWishes
        ..clear()
        ..addAll(approved);

      return true;
    } catch (_) {
      if (showLoading || isEmpty) {
        _hasError = true;
      }

      return false;
    } finally {
      _isLoading = false;
      _requestRunning = false;
      _notify();
    }
  }

  Future<bool> refresh() {
    return loadWishes(showLoading: false);
  }

  Future<bool> approveWish(String wishId, int targetPoints) async {
    try {
      final approvedWish = await _wishlistApiService.approveWish(
        wishId,
        targetPoints,
      );

      final index = _pendingWishes.indexWhere(
        (entry) => entry.wish.id == wishId,
      );

      if (index != -1) {
        final approvedEntry = _pendingWishes
            .removeAt(index)
            .copyWith(wish: approvedWish, approvedPoints: targetPoints);

        _approvedWishes.insert(0, approvedEntry);
        _notify();
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectWish(String wishId) async {
    try {
      await _wishlistApiService.rejectWish(wishId);

      _pendingWishes.removeWhere((entry) => entry.wish.id == wishId);

      _notify();
      return true;
    } catch (_) {
      return false;
    }
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
