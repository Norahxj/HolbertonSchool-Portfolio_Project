import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_refresh_indicator.dart';
import '../../../core/widgets/child_avatar.dart';
import '../../../core/widgets/screen_background.dart';
import '../controllers/wishlist_approval_controller.dart';

class WishlistApprovalScreen extends StatelessWidget {
  final bool isArabic;

  const WishlistApprovalScreen({
    super.key,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          WishlistApprovalController()..loadWishes(),
      child: _WishlistApprovalView(
        isArabic: isArabic,
      ),
    );
  }
}

class _WishlistApprovalView extends StatelessWidget {
  final bool isArabic;

  const _WishlistApprovalView({
    required this.isArabic,
  });

  Future<void> _refresh(BuildContext context) async {
    final success = await context
        .read<WishlistApprovalController>()
        .refresh();

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تعذّر تحديث الأمنيات'
                : 'Unable to refresh wishes',
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

  Future<void> _rejectWish(
    BuildContext context,
    String wishId,
  ) async {
    final success = await context
        .read<WishlistApprovalController>()
        .rejectWish(wishId);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تعذّر رفض الأمنية'
                : 'Unable to reject the wish',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        context.watch<WishlistApprovalController>();

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: AppRefreshIndicator(
            onRefresh: () => _refresh(context),
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isArabic
                        ? 'موافقة الأمنيات'
                        : 'Wish Approval',
                    style: AppTextStyles.arabicTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    isArabic
                        ? 'راجع أمنيات أطفالك وحدّد نقاط نور المطلوبة'
                        : 'Review your children’s wishes and set the required Noor points',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (controller.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child:
                            CircularProgressIndicator(),
                      ),
                    )
                  else if (controller.hasError &&
                      controller.isEmpty)
                    _ErrorState(
                      isArabic: isArabic,
                      onRetry: () {
                        controller.loadWishes();
                      },
                    )
                  else if (controller.isEmpty)
                    _EmptyState(isArabic: isArabic)
                  else ...[
                    for (final entry
                        in controller.pendingWishes) ...[
                      _PendingWishCard(
                        key: ValueKey(entry.wish.id),
                        childName: entry.childName,
                        isArabic: isArabic,
                        avatarIndex: entry.avatarIndex,
                        wishTitle: entry.wish.name,
                        subtitle: isArabic
                            ? 'أضاف هذه الأمنية إلى قائمته'
                            : 'Added this wish to the list',
                        startingPoints:
                            entry.wish.targetPoints ?? 250,
                        onApprove: (points) {
                          _approveWish(
                            context,
                            entry.wish.id,
                            points,
                          );
                        },
                        onReject: () {
                          _rejectWish(
                            context,
                            entry.wish.id,
                          );
                        },
                      ),
                      const SizedBox(
                        height: AppSpacing.md,
                      ),
                    ],

                    for (final entry
                        in controller.approvedWishes) ...[
                      _ApprovedWishCard(
                        childName: entry.childName,
                        isArabic: isArabic,
                        avatarIndex: entry.avatarIndex,
                        wishTitle: entry.wish.name,
                        subtitle: isArabic
                            ? 'تمت الموافقة على هذه الأمنية'
                            : 'This wish has been approved',
                        points: entry.approvedPoints ??
                            entry.wish.targetPoints ??
                            0,
                      ),
                      const SizedBox(
                        height: AppSpacing.md,
                      ),
                    ],
                  ],

                  const SizedBox(height: AppSpacing.sm),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      isArabic
                          ? 'عند الموافقة تُخصم نقاط نور من رصيد الطفل مقابل الأمنية'
                          : 'When approved, Noor points are deducted from the child’s balance for the wish',
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

class _ErrorState extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.isArabic,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
           isArabic
                ? 'حدث خطأ أثناء تحميل الأمنيات. حاول مرة أخرى.'
                : 'An error occurred while loading wishes. Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(
             isArabic
                  ? 'إعادة المحاولة'
                  : 'Try Again',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isArabic;

  const _EmptyState({
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          isArabic
              ? 'لا توجد أمنيات بعد.'
              : 'No wishes yet.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusTag({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class _WishHeader extends StatelessWidget {
  final String childName;
  final String wishTitle;
  final int avatarIndex;
  final bool isArabic;

  const _WishHeader({
    required this.childName,
    required this.wishTitle,
    required this.avatarIndex,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Expanded(
          child: Text(
            '$childName . $wishTitle',
            textAlign: isArabic
                ? TextAlign.right
                : TextAlign.left,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ChildAvatar(
          avatarIndex: avatarIndex,
          size: 40,
        ),
      ],
    );
  }
}

class _PendingWishCard extends StatefulWidget {
  final String childName;
  final bool isArabic;
  final int avatarIndex;
  final String wishTitle;
  final String subtitle;
  final int startingPoints;
  final ValueChanged<int> onApprove;
  final VoidCallback onReject;

  const _PendingWishCard({
    super.key,
    required this.childName,
    required this.avatarIndex,
    required this.wishTitle,
    required this.subtitle,
    required this.startingPoints,
    required this.onApprove,
    required this.onReject,
    required this.isArabic,
  });

  @override
  State<_PendingWishCard> createState() =>
      _PendingWishCardState();
}

class _PendingWishCardState
    extends State<_PendingWishCard> {
  late int requiredPoints;

  @override
  void initState() {
    super.initState();
    requiredPoints = widget.startingPoints;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          _WishHeader(
            childName: widget.childName,
            wishTitle: widget.wishTitle,
            avatarIndex: widget.avatarIndex,
            isArabic: widget.isArabic,
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              _StatusTag(
                label: widget.isArabic
                    ? 'بانتظار الموافقة'
                    : 'Pending Approval',
                backgroundColor:
                    AppColors.primaryLight,
                textColor: AppColors.primaryDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.subtitle,
                  textAlign: widget.isArabic
                      ? TextAlign.right
                      : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              children: [
                _StepperButton(
                  icon: Icons.add,
                  isFilled: true,
                  onTap: () {
                    setState(() {
                      requiredPoints += 10;
                    });
                  },
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Text(
                  '$requiredPoints',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.gold,
                  size: 16,
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                _StepperButton(
                  icon: Icons.remove,
                  isFilled: false,
                  onTap: () {
                    if (requiredPoints > 10) {
                      setState(() {
                        requiredPoints -= 10;
                      });
                    }
                  },
                ),
                const Spacer(),
                Text(
                  widget.isArabic
                      ? 'نقاط نور المطلوبة'
                      : 'Required Noor Points',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    if (requiredPoints <= 0) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.isArabic
                                ? 'يجب أن تكون النقاط أكبر من صفر'
                                : 'Points must be greater than zero',
                          ),
                        ),
                      );
                      return;
                    }

                    widget.onApprove(
                      requiredPoints,
                    );
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.isArabic
                                ? 'موافقة وخصم النقاط'
                                : 'Approve and Deduct Points',
                            textAlign:
                                TextAlign.center,
                            maxLines: 2,
                            style:
                                const TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onReject,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.isArabic
                              ? 'رفض'
                              : 'Reject',
                          style:
                              const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.bold,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.close,
                          color: AppColors
                              .textPrimary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool isFilled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.isFilled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isFilled
              ? AppColors.primary
              : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isFilled
              ? Colors.white
              : AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _ApprovedWishCard extends StatelessWidget {
  final String childName;
  final int avatarIndex;
  final String wishTitle;
  final String subtitle;
  final int points;
  final bool isArabic;

  const _ApprovedWishCard({
    required this.childName,
    required this.isArabic,
    required this.avatarIndex,
    required this.wishTitle,
    required this.subtitle,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBFE3C6),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          _WishHeader(
            childName: childName,
            wishTitle: wishTitle,
            avatarIndex: avatarIndex,
            isArabic: isArabic,
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              _StatusTag(
                label: isArabic
                    ? 'معتمدة'
                    : 'Approved',
                backgroundColor:
                    AppColors.success,
                textColor: Colors.white,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  subtitle,
                  textAlign: isArabic
                      ? TextAlign.right
                      : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Text(
                  '$points',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.gold,
                  size: 16,
                ),
                const Spacer(),
                Text(
                  isArabic
                      ? 'تم خصمها من رصيده'
                      : 'Deducted from the balance',
                  style: const TextStyle(
                    fontSize: 13,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
