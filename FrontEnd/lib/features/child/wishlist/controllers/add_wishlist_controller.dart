import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/wishlist_action_result.dart';
import '../repositories/child_wishlist_repository.dart';

class AddWishlistController extends ChangeNotifier {
  static const int maximumPendingWishes = 5;

  final ChildWishlistRepository _repository;

  AddWishlistController({
    ChildWishlistRepository? repository,
  }) : _repository =
            repository ?? ChildWishlistRepository();

  int _pendingWishesCount = 0;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDisposed = false;

  WishlistErrorCode? _errorCode;

  int get pendingWishesCount => _pendingWishesCount;

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  WishlistErrorCode? get errorCode => _errorCode;

  bool get hasReachedLimit {
    return _pendingWishesCount >= maximumPendingWishes;
  }

  Future<void> loadCurrentWishes() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorCode = null;
    _notify();

    try {
      final wishes = await _repository.getWishes();

      _pendingWishesCount = wishes.where((wish) {
        return wish.status.toUpperCase() == 'PENDING';
      }).length;
    } catch (error, stackTrace) {
      _errorCode = WishlistErrorCode.loadFailed;

      debugPrint(
        'Loading wishes failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  WishlistErrorCode? validateName(String name) {
    if (name.length < 2) {
      return WishlistErrorCode.nameTooShort;
    }

    if (name.length > 255) {
      return WishlistErrorCode.nameTooLong;
    }

    return null;
  }

  Future<WishlistActionResult> createWish(
    String name,
  ) async {
    final validationError = validateName(name);

    if (validationError != null) {
      return WishlistActionResult.failure(
        errorCode: validationError,
      );
    }

    if (hasReachedLimit) {
      return const WishlistActionResult.failure(
        errorCode: WishlistErrorCode.wishlistLimitReached,
      );
    }

    if (_isSaving) {
      return const WishlistActionResult.success();
    }

    _isSaving = true;
    _notify();

    try {
      await _repository.createWish(name);

      return const WishlistActionResult.success();
    } on DioException catch (error) {
      final backendMessage = _readBackendMessage(error);

      return WishlistActionResult.failure(
        errorCode: _isWishlistLimitError(error)
            ? WishlistErrorCode.wishlistLimitReached
            : WishlistErrorCode.createFailed,
        backendMessage: backendMessage,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Creating wish failed: '
        '$error\n$stackTrace',
      );

      return const WishlistActionResult.failure(
        errorCode: WishlistErrorCode.createFailed,
      );
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  bool _isWishlistLimitError(DioException error) {
    final data = error.response?.data;

    if (data is! Map) {
      return false;
    }

    return data['error']
            ?.toString()
            .contains('Wishlist limit reached') ==
        true;
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is! Map) {
      return null;
    }

    final errors = data['errors'];

    if (errors is Map) {
      final nameErrors = errors['name'];

      if (nameErrors is List && nameErrors.isNotEmpty) {
        return nameErrors.first.toString();
      }
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