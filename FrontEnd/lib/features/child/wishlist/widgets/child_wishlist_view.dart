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
  final Future<void> Function(
    String wishId,
    String wishName,
  ) onDeleteWish;
  final Future<void> Function(
    String wishId,
  ) onAchieveWish;

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
    final controller =
        context.watch<ChildWishlistController>();

    if (controller.hasError &&
        controller.wishes.isEmpty &&
        !controller.isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.backendMessage ??
                          context.l10n.childWishlistLoadFailed,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    ElevatedButton(
                      onPressed: onRetry,
                      child: Text(
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
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldLight,
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Text(
                              controller.isLoading
                                  ? '—'
                                  : '${controller.points}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.auto_awesome,
                              color: AppColors.gold,
                              size: 14,
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Text(
                          context.l10n.childWishlistTitle,
                          textAlign: TextAlign.center,
                          style:
                              AppTextStyles.arabicTitle,
                        ),
                      ),

                      const SizedBox(width: 56),
                    ],
                  ),

                  const SizedBox(
                    height: AppSpacing.sm,
                  ),

                  Text(
                    context.l10n.childWishlistSubtitle,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  if (controller.isLoading &&
                      wishes.isEmpty)
                    const Center(
                      child: Padding(
                        padding:
                            EdgeInsets.all(32),
                        child:
                            CircularProgressIndicator(),
                      ),
                    )
                  else if (wishes.isEmpty)
                    _EmptyWishlistState(
                      onAddWish: onAddWish,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: wishes.length,
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(
                        height: AppSpacing.md,
                      ),
                      itemBuilder:
                          (context, index) {
                        final wish = wishes[index];

                        return WishCard(
                          wish: wish,
                          currentPoints:
                              controller.points,
                          onDelete: () {
                            onDeleteWish(
                              wish.id,
                              wish.name,
                            );
                          },
                          onAchieve: () {
                            onAchieveWish(
                              wish.id,
                            );
                          },
                        );
                      },
                    ),

                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  GestureDetector(
                    onTap: onAddWish,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.childAddWish,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  AppColors.primary,
                            ),
                          ),
                          const SizedBox(
                            width: AppSpacing.sm,
                          ),
                          const Icon(
                            Icons.add,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
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
}

class _EmptyWishlistState extends StatelessWidget {
  final VoidCallback onAddWish;

  const _EmptyWishlistState({
    required this.onAddWish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(
            height: AppSpacing.md,
          ),
          Text(
            context.l10n.childWishlistEmpty,
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          Text(
            context.l10n.childWishlistEmptySubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}