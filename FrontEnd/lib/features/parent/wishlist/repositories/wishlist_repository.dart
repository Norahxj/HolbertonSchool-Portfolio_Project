import '../../../../models/wish_model.dart';
import '../../../../services/wishlist_api_service.dart';

class WishlistRepository {
  final WishlistApiService _apiService;

  WishlistRepository({
    WishlistApiService? apiService,
  }) : _apiService = apiService ?? WishlistApiService();

  Future<List<WishModel>> getFamilyWishes() {
    return _apiService.getFamilyWishes();
  }

  Future<WishModel> approveWish(
    String wishId,
    int targetPoints,
  ) {
    return _apiService.approveWish(
      wishId,
      targetPoints,
    );
  }

  Future<void> rejectWish(String wishId) {
    return _apiService.rejectWish(wishId);
  }
}