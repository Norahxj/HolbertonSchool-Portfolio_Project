import '../../../../models/wish_model.dart';

class ChildWishlistData {
  final List<WishModel> wishes;
  final int points;

  const ChildWishlistData({
    required this.wishes,
    required this.points,
  });
}