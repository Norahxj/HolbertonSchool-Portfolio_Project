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

typedef ApproveWishCallback = Future<void> Function({
  required String wishId,
  required int targetPoints,
});

typedef RejectWishCallback = Future<void> Function({
  required String wishId,
});

class WishlistApprovalView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final ApproveWishCallback onApprove;
  final RejectWishCallback onReject;

  const WishlistApprovalView({
    super.key,
    required this.onRefresh,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        context.watch<WishlistApprovalController>();

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: AppRefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const _WishlistPageHeader(),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  _WishlistContent(
                    controller: controller,
                    onApprove: onApprove,
                    onReject: onReject,
                  ),

                  const SizedBox(
                    height: AppSpacing.sm,
                  ),

                  Padding(
                    padding:
                        const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      context.l10n.wishApprovalExplanation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WishlistPageHeader extends StatelessWidget {
  const _WishlistPageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.childrenWishes,
          style: AppTextStyles.arabicTitle,
          textAlign: TextAlign.center,
        ),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        Text(
          context.l10n.childrenWishesSubtitle,
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _WishlistContent extends StatelessWidget {
  final WishlistApprovalController controller;
  final ApproveWishCallback onApprove;
  final RejectWishCallback onReject;

  const _WishlistContent({
    required this.controller,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const WishlistLoadingState();
    }

    if (controller.hasError && controller.isEmpty) {
      return WishlistErrorState(
        onRetry: controller.loadWishes,
      );
    }

    if (controller.isEmpty) {
      return const WishlistEmptyState();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        for (final entry
            in controller.pendingWishes) ...[
          PendingWishCard(
            key: ValueKey(entry.wish.id),
            childName: entry.childName,
            avatarIndex: entry.avatarIndex,
            wishTitle: entry.wish.name,
            startingPoints:
                entry.wish.targetPoints ?? 250,
            isProcessing:
                controller.isWishProcessing(
              entry.wish.id,
            ),
            onApprove: (targetPoints) {
              return onApprove(
                wishId: entry.wish.id,
                targetPoints: targetPoints,
              );
            },
            onReject: () {
              return onReject(
                wishId: entry.wish.id,
              );
            },
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),
        ],

        for (final entry
            in controller.approvedWishes) ...[
          ApprovedWishCard(
            key: ValueKey(entry.wish.id),
            childName: entry.childName,
            avatarIndex: entry.avatarIndex,
            wishTitle: entry.wish.name,
            points:
                entry.approvedPoints ??
                entry.wish.targetPoints ??
                0,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),
        ],

        for (final entry
            in controller.achievedWishes) ...[
          AchievedWishCard(
            key: ValueKey(entry.wish.id),
            childName: entry.childName,
            avatarIndex: entry.avatarIndex,
            wishTitle: entry.wish.name,
            points:
                entry.wish.targetPoints ?? 0,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),
        ],
      ],
    );
  }
}