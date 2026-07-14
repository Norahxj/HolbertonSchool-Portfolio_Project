import '../core/network/api_service.dart';
import '../core/network/dio_factory.dart';
import '../models/wish_model.dart';

class WishlistApiService {
  final ApiService _apiService = ApiService(DioFactory.getDio());

  /// Child: Get all my wishes

  Future<List<WishModel>> getMyWishes() async {
    final response = await _apiService.getMyWishes();
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => WishModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Child: Create a new wish (only sends the name)

  Future<WishModel> createWish(String name) async {
    final response = await _apiService.createWish({'name': name});
    return WishModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Child: Mark a wish as achieved (deducts points automatically)

  Future<WishModel> achieveWish(String wishId) async {
    final response = await _apiService.achieveWish(wishId);
    return WishModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Child: Delete a pending or rejected wish -

  Future<void> deleteWish(String wishId) async {
    await _apiService.deleteWish(wishId);
  }

  /// Parent: Get a specific child's wishes - 

  Future<List<WishModel>> getChildWishes(String childId) async {
    final response = await _apiService.getChildWishes(childId);
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => WishModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Parent: Approve a wish and set how many points it costs -

  Future<WishModel> approveWish(String wishId, int targetPoints) async {
    final response = await _apiService.approveWish(
      wishId,
      {'target_points': targetPoints},
    );
    return WishModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Parent: Reject a wish -
  Future<WishModel> rejectWish(String wishId) async {
    final response = await _apiService.rejectWish(wishId);
    return WishModel.fromJson(response.data as Map<String, dynamic>);
  }
}
