import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/wishlist_approval_controller.dart';
import '../widgets/wishlist_approval_view.dart';

class WishlistApprovalScreen extends StatelessWidget {
  const WishlistApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return WishlistApprovalController()..loadWishes();
      },
      child: const WishlistApprovalView(),
    );
  }
}
