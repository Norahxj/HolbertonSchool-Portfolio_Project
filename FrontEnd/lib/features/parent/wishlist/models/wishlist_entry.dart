import '../../../../models/wish_model.dart';

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
