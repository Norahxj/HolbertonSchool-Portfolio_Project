import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_refresh_indicator.dart';
import '../../../core/widgets/screen_background.dart';
import '../controllers/wishlist_approval_controller.dart';
import '../wishlist/widgets/pending_wish_card.dart';
import '../wishlist/widgets/achieved_wish_card.dart';
import '../wishlist/widgets/approved_wish_card.dart';
import '../wishlist/widgets/wishlist_states.dart';

class WishlistApprovalScreen extends StatelessWidget {
  final bool isArabic;

  const WishlistApprovalScreen({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WishlistApprovalController()..loadWishes(),
      child: _WishlistApprovalView(isArabic: isArabic),
    );
  }
}

class _WishlistApprovalView extends StatelessWidget {
  final bool isArabic;

  const _WishlistApprovalView({required this.isArabic});

  Future<void> _refresh(BuildContext context) async {
    final success = await context.read<WishlistApprovalController>().refresh();

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'تعذّر تحديث الأمنيات' : 'Unable to refresh wishes',
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تعذّرت الموافقة على الأمنية'
                : 'Unable to approve the wish',
          ),
        ),
      );
    }
  }

  Future<void> _rejectWish(BuildContext context, String wishId) async {
    final success = await context.read<WishlistApprovalController>().rejectWish(
      wishId,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'تعذّر رفض الأمنية' : 'Unable to reject the wish',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WishlistApprovalController>();

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: AppRefreshIndicator(
            onRefresh: () => _refresh(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isArabic ? 'أمنيات الأطفال' : 'Children’s Wishes',
                    style: AppTextStyles.arabicTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    isArabic
                        ? 'راجع أمنية طفلك وحدد عدد نقاط نور التي يحتاج لجمعها حتى يتمكن من تحقيقها'
                        : 'Review your child’s wish and set how many Noor points they need to collect to achieve it',
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
                    WishlistErrorState(
                      isArabic: isArabic,
                      onRetry: () {
                        controller.loadWishes();
                      },
                    )
                  else if (controller.isEmpty)
                    WishlistEmptyState(isArabic: isArabic)
                  else ...[
                    for (final entry in controller.pendingWishes) ...[
                      PendingWishCard(
                        key: ValueKey(entry.wish.id),
                        childName: entry.childName,
                        isArabic: isArabic,
                        avatarIndex: entry.avatarIndex,
                        wishTitle: entry.wish.name,
                        subtitle: isArabic
                            ? 'طلب هذه الأمنية وينتظر منك تحديد هدف النقاط'
                            : 'Requested this wish and is waiting for you to set the points goal',
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
                        isArabic: isArabic,
                        avatarIndex: entry.avatarIndex,
                        wishTitle: entry.wish.name,
                        subtitle: isArabic
                            ? 'تمت الموافقة على هذه الأمنية'
                            : 'This wish has been approved',
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
                        isArabic: isArabic,
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
                      isArabic
                          ? 'بعد اعتماد الأمنية، يبدأ الطفل بجمع نقاط نور حتى يصل إلى الهدف المحدد.'
                          : 'After the wish is approved, the child starts collecting Noor points until reaching the selected goal.',
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
