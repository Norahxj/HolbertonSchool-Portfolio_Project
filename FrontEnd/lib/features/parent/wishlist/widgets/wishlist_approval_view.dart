import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/wishlist_approval_controller.dart';
import 'achieved_wish_card.dart';
import 'approved_wish_card.dart';
import 'pending_wish_card.dart';
import 'wishlist_states.dart';

class WishlistApprovalView extends StatelessWidget {
  const WishlistApprovalView({super.key});

  Future<void> _refresh(BuildContext context) async {
    final success = await context.read<WishlistApprovalController>().refresh();

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.failedToRefreshWishes)),
      );
    }
  }

  Future<void> _approveWish(
    BuildContext context,
    String wishId,
    int targetPoints,
  ) async {
    final success = await context
        .read<WishlistApprovalController>()
        .approveWish(wishId, targetPoints);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.failedToApproveWish)));
    }
  }

  Future<void> _rejectWish(BuildContext context, String wishId) async {
    final success = await context.read<WishlistApprovalController>().rejectWish(
      wishId,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.failedToRejectWish)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WishlistApprovalController>();

    final l10n = context.l10n;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: AppRefreshIndicator(
            onRefresh: () {
              return _refresh(context);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.childrenWishes,
                    style: AppTextStyles.arabicTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    l10n.childrenWishesSubtitle,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (controller.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (controller.hasError && controller.isEmpty)
                    WishlistErrorState(onRetry: controller.loadWishes)
                  else if (controller.isEmpty)
                    const WishlistEmptyState()
                  else ...[
                    for (final entry in controller.pendingWishes) ...[
                      PendingWishCard(
                        key: ValueKey(entry.wish.id),
                        childName: entry.childName,
                        avatarIndex: entry.avatarIndex,
                        wishTitle: entry.wish.name,
                        startingPoints: entry.wish.targetPoints ?? 250,
                        onApprove: (points) {
                          _approveWish(context, entry.wish.id, points);
                        },
                        onReject: () {
                          _rejectWish(context, entry.wish.id);
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),
                    ],

                    for (final entry in controller.approvedWishes) ...[
                      ApprovedWishCard(
                        childName: entry.childName,
                        avatarIndex: entry.avatarIndex,
                        wishTitle: entry.wish.name,
                        points:
                            entry.approvedPoints ??
                            entry.wish.targetPoints ??
                            0,
                      ),

                      const SizedBox(height: AppSpacing.md),
                    ],

                    for (final entry in controller.achievedWishes) ...[
                      AchievedWishCard(
                        childName: entry.childName,
                        avatarIndex: entry.avatarIndex,
                        wishTitle: entry.wish.name,
                        points: entry.wish.targetPoints ?? 0,
                      ),

                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],

                  const SizedBox(height: AppSpacing.sm),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      l10n.wishApprovalExplanation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
