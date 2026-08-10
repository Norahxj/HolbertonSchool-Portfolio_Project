import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/child_wishlist_controller.dart';
import 'wish_card.dart';

class ChildWishlistView extends StatelessWidget {
  final VoidCallback onAddWish;
  final Future<void> Function() onRetry;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String wishId, String wishName) onDeleteWish;
  final Future<void> Function(String wishId) onAchieveWish;

  const ChildWishlistView({
    super.key,
    required this.onAddWish,
    required this.onRetry,
    required this.onRefresh,
    required this.onDeleteWish,
    required this.onAchieveWish,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChildWishlistController>();

    if (controller.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (controller.hasError) {
      final message =
          controller.backendMessage ??
          context.l10n.childWishlistLoadFailed;

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.error,
                      size: 52,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: Text(
                        context.l10n.retry,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final wishes = controller.wishes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.childWishlistTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.arabicTitle,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    context.l10n.childWishlistSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            context.l10n.childWishlistPoints(
                              controller.points,
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  FilledButton.icon(
                    onPressed: onAddWish,
                    icon: const Icon(
                      Icons.add_rounded,
                    ),
                    label: Text(
                      context.l10n.childAddWish,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (wishes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(
                        AppSpacing.xl,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.star_border_rounded,
                            color: AppColors.primary,
                            size: 48,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            context.l10n.childWishlistEmpty,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.sectionTitle,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            context.l10n.childWishlistEmptySubtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: wishes.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(
                            height: AppSpacing.md,
                          ),
                      itemBuilder: (context, index) {
                        final wish = wishes[index];

                        return WishCard(
                          wish: wish,
                          currentPoints: controller.points,
                          onDelete: () => onDeleteWish(
                            wish.id,
                            wish.name,
                          ),
                          onAchieve: () => onAchieveWish(
                            wish.id,
                          ),
                        );
                      },
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