import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_refresh_indicator.dart';
import '../../../models/wish_model.dart';
import '../controllers/child_wishlist_controller.dart';
import 'add_wishlist_screen.dart';

class ChildWishlistScreen extends StatelessWidget {
  final bool isArabic;

  const ChildWishlistScreen({
    super.key,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ChildWishlistController()..loadData(),
      child: _ChildWishlistView(
        isArabic: isArabic,
      ),
    );
  }
}

class _ChildWishlistView extends StatelessWidget {
  final bool isArabic;

  const _ChildWishlistView({
    required this.isArabic,
  });

  Future<void> _refresh(BuildContext context) async {
    final success = await context
        .read<ChildWishlistController>()
        .refresh();

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تعذّر تحديث قائمة الأمنيات'
                : 'Unable to refresh the wishlist',
          ),
        ),
      );
    }
  }

  Future<void> _deleteWish(
    BuildContext context,
    String wishId,
  ) async {
    final success = await context
        .read<ChildWishlistController>()
        .deleteWish(wishId);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تعذّر حذف الأمنية'
                : 'Could not delete the wish',
          ),
        ),
      );
    }
  }

  Future<void> _achieveWish(
    BuildContext context,
    String wishId,
  ) async {
    final success = await context
        .read<ChildWishlistController>()
        .achieveWish(wishId);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تعذّر تحقيق الأمنية — تحقق من رصيد نقاطك'
                : 'Could not achieve the wish. Check your points balance.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        context.watch<ChildWishlistController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                            style:
                                const TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.bold,
                              color: AppColors
                                  .textPrimary,
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
                        isArabic
                            ? 'قائمة أمنياتي'
                            : 'My Wishlist',
                        textAlign: TextAlign.center,
                        textDirection: isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
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
                  isArabic
                      ? 'اجمع نقاط نور لتحقيق أمنياتك'
                      : 'Collect Noor Points to achieve your wishes',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                if (controller.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child:
                          CircularProgressIndicator(),
                    ),
                  )
                else if (controller.hasError &&
                    controller.wishes.isEmpty)
                  _ErrorState(
                    isArabic: isArabic,
                    onRetry: () {
                      controller.loadData();
                    },
                  )
                else if (controller.wishes.isEmpty)
                  _EmptyState(isArabic: isArabic)
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        controller.wishes.length,
                    separatorBuilder:
                        (context, index) =>
                            const SizedBox(
                      height: AppSpacing.md,
                    ),
                    itemBuilder: (context, index) {
                      final wish =
                          controller.wishes[index];

                      return _WishCard(
                        wish: wish,
                        currentPoints:
                            controller.points,
                        isArabic: isArabic,
                        onDelete: () {
                          _deleteWish(
                            context,
                            wish.id,
                          );
                        },
                        onAchieve: () {
                          _achieveWish(
                            context,
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
                  onTap: () async {
                    final wasAdded =
                        await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddWishlistScreen(
                          isArabic: isArabic,
                        ),
                      ),
                    );

                    if (!context.mounted) return;

                    if (wasAdded == true) {
                      await controller.refresh();
                    }
                  },
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
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      children: [
                        Text(
                          isArabic
                              ? 'إضافة أمنية'
                              : 'Add a wish',
                          textDirection: isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          style:
                              const TextStyle(
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
                ? 'حدث خطأ أثناء تحميل البيانات. حاول مرة أخرى.'
                : 'An error occurred while loading the data. Please try again.',
            textAlign: TextAlign.center,
            textDirection: isArabic
                ? TextDirection.rtl
                : TextDirection.ltr,
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
                  : 'Try again',
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
              ? 'لا توجد أمنيات بعد.\nأضف أمنيتك الأولى!'
              : 'There are no wishes yet.\nAdd your first wish!',
          textAlign: TextAlign.center,
          textDirection: isArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _WishCard extends StatelessWidget {
  final WishModel wish;
  final int currentPoints;
  final bool isArabic;
  final VoidCallback onDelete;
  final VoidCallback onAchieve;

  const _WishCard({
    required this.wish,
    required this.currentPoints,
    required this.isArabic,
    required this.onDelete,
    required this.onAchieve,
  });

  String get _statusLabel {
    switch (wish.status.toUpperCase()) {
      case 'APPROVED':
        return isArabic
            ? 'مقبولة ✓'
            : 'Approved ✓';
      case 'REJECTED':
        return isArabic
            ? 'مرفوضة ✗'
            : 'Rejected ✗';
      case 'ACHIEVED':
        return isArabic
            ? 'تحققت! 🌟'
            : 'Achieved! 🌟';
      default:
        return isArabic
            ? 'في الانتظار...'
            : 'Pending...';
    }
  }

  Color get _statusColor {
    switch (wish.status.toUpperCase()) {
      case 'APPROVED':
        return AppColors.success;
      case 'REJECTED':
        return Colors.red;
      case 'ACHIEVED':
        return AppColors.gold;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = wish.status.toUpperCase();
    final target = wish.targetPoints;

    final hasProgress =
        status == 'APPROVED' &&
        target != null &&
        target > 0;

    final progressValue = hasProgress
        ? (currentPoints / target)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: isArabic
                ? TextDirection.ltr
                : TextDirection.rtl,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      wish.name,
                      textAlign: isArabic
                          ? TextAlign.right
                          : TextAlign.left,
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusLabel,
                      textAlign: isArabic
                          ? TextAlign.right
                          : TextAlign.left,
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.star,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),

          if (hasProgress) ...[
            const SizedBox(
              height: AppSpacing.md,
            ),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(8),
              child:
                  LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                backgroundColor:
                    AppColors.primaryLight,
                valueColor:
                    const AlwaysStoppedAnimation(
                  AppColors.primary,
                ),
              ),
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic
                      ? 'الهدف: $target نقطة'
                      : 'Target: $target points',
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color: AppColors
                        .textSecondary,
                  ),
                ),
                Text(
                  isArabic
                      ? 'لديك: $currentPoints نقطة'
                      : 'You have: $currentPoints points',
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color: AppColors
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ],

          if (status == 'APPROVED') ...[
            const SizedBox(
              height: AppSpacing.md,
            ),
            ElevatedButton(
              onPressed:
                  target != null &&
                          currentPoints >= target
                      ? onAchieve
                      : null,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primaryLight,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: Text(
                target == null
                    ? isArabic
                        ? 'لم يتم تحديد النقاط المطلوبة'
                        : 'Required points were not specified'
                    : currentPoints >= target
                        ? isArabic
                            ? 'لقد حققت أمنيتي! 🌟'
                            : 'I achieved my wish! 🌟'
                        : isArabic
                            ? 'اجمع المزيد من النقاط'
                            : 'Collect more points',
                textDirection: isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],

          if (status == 'PENDING' ||
              status == 'REJECTED') ...[
            const SizedBox(
              height: AppSpacing.sm,
            ),
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 18,
              ),
              label: Text(
                isArabic
                    ? 'حذف'
                    : 'Delete',
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
