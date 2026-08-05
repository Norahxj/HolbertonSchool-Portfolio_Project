import 'package:flutter/foundation.dart';

import '../../../models/wish_model.dart';
import '../../../services/wishlist_api_service.dart';
import '../services/point_api_service.dart';

class ChildWishlistController extends ChangeNotifier {
  ChildWishlistController({
    WishlistApiService? wishlistApiService,
    PointApiService? pointApiService,
  }) : _wishlistApiService = wishlistApiService ?? WishlistApiService(),
       _pointApiService = pointApiService ?? PointApiService();

  final WishlistApiService _wishlistApiService;
  final PointApiService _pointApiService;

  List<WishModel> _wishes = [];
  int _points = 0;

  bool _isLoading = true;
  bool _hasError = false;
  bool _requestRunning = false;
  bool _isDisposed = false;

  List<WishModel> get wishes => List.unmodifiable(_wishes);
  int get points => _points;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  Future<bool> loadData({bool showLoading = true}) async {
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
      final results = await Future.wait([
        _wishlistApiService.getMyWishes(),
        _pointApiService.getMyPoints(),
      ]);

      _wishes = results[0] as List<WishModel>;
      _points = results[1] as int;

      return true;
    } catch (_) {
      if (showLoading || _wishes.isEmpty) {
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
    return loadData(showLoading: false);
  }

  Future<bool> deleteWish(String wishId) async {
    try {
      await _wishlistApiService.deleteWish(wishId);

      _wishes.removeWhere((wish) => wish.id == wishId);

      _notify();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> achieveWish(String wishId) async {
    try {
      await _wishlistApiService.achieveWish(wishId);

      // The points balance changes after achieving a wish, so reload both
      // wishes and points without replacing the screen with a loading spinner.
      await loadData(showLoading: false);

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
