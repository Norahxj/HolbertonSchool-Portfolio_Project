import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/wish_model.dart';
import '../models/wishlist_action_result.dart';
import '../repositories/child_wishlist_repository.dart';

class ChildWishlistController extends ChangeNotifier {
  final ChildWishlistRepository _repository;

  ChildWishlistController({
    ChildWishlistRepository? repository,
  }) : _repository =
            repository ?? ChildWishlistRepository();

  List<WishModel> _wishes = [];
  int _points = 0;

  bool _isLoading = false;
  bool _isDisposed = false;

  WishlistErrorCode? _errorCode;
  String? _backendMessage;

  List<WishModel> get wishes {
    return List.unmodifiable(_wishes);
  }

  int get points => _points;

  bool get isLoading => _isLoading;

  WishlistErrorCode? get errorCode => _errorCode;

  String? get backendMessage => _backendMessage;

  bool get hasError => _errorCode != null;

  Future<void> loadWishlist() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _clearError();
    _notify();

    try {
      final data = await _repository.getWishlistData();

      _wishes = data.wishes;
      _points = data.points;
    } on DioException catch (error) {
      _errorCode = WishlistErrorCode.loadFailed;
      _backendMessage = _readBackendMessage(error);
    } catch (error, stackTrace) {
      _errorCode = WishlistErrorCode.loadFailed;

      debugPrint(
        'Loading child wishlist failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<WishlistActionResult> deleteWish(
    String wishId,
  ) async {
    try {
      await _repository.deleteWish(wishId);
      await loadWishlist();

      return const WishlistActionResult.success();
    } on DioException catch (error) {
      return WishlistActionResult.failure(
        errorCode: WishlistErrorCode.deleteFailed,
        backendMessage: _readBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Deleting child wish failed: '
        '$error\n$stackTrace',
      );

      return const WishlistActionResult.failure(
        errorCode: WishlistErrorCode.deleteFailed,
      );
    }
  }

  Future<WishlistActionResult> achieveWish(
    String wishId,
  ) async {
    try {
      await _repository.achieveWish(wishId);
      await loadWishlist();

      return const WishlistActionResult.success();
    } on DioException catch (error) {
      return WishlistActionResult.failure(
        errorCode: WishlistErrorCode.achieveFailed,
        backendMessage: _readBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Achieving child wish failed: '
        '$error\n$stackTrace',
      );

      return const WishlistActionResult.failure(
        errorCode: WishlistErrorCode.achieveFailed,
      );
    }
  }

  void _clearError() {
    _errorCode = null;
    _backendMessage = null;
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is! Map) {
      return null;
    }

    final errorMessage = data['error']?.toString().trim();

    if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }

    final message = data['message']?.toString().trim();

    if (message == null || message.isEmpty) {
      return null;
    }

    return message;
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