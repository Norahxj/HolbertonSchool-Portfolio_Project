import '../../../../models/wish_model.dart';
import '../../../../services/wishlist_api_service.dart';
import '../../services/point_api_service.dart';
import '../models/child_wishlist_data.dart';

class ChildWishlistRepository {
  final WishlistApiService _wishlistApiService;
  final PointApiService _pointApiService;

  ChildWishlistRepository({
    WishlistApiService? wishlistApiService,
    PointApiService? pointApiService,
  }) : _wishlistApiService =
            wishlistApiService ?? WishlistApiService(),
       _pointApiService =
            pointApiService ?? PointApiService();

  Future<ChildWishlistData> getWishlistData() async {
    final results = await Future.wait([
      _wishlistApiService.getMyWishes(),
      _pointApiService.getMyPoints(),
    ]);

    return ChildWishlistData(
      wishes: results[0] as List<WishModel>,
      points: results[1] as int,
    );
  }

  Future<List<WishModel>> getWishes() async {
    return _wishlistApiService.getMyWishes();
  }

  Future<void> deleteWish(String wishId) async {
    await _wishlistApiService.deleteWish(wishId);
  }

  Future<void> achieveWish(String wishId) async {
    await _wishlistApiService.achieveWish(wishId);
  }

  Future<void> createWish(String name) async {
    await _wishlistApiService.createWish(name);
  }
}