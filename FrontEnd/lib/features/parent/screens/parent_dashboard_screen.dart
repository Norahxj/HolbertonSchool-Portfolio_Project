import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import '../controllers/parent_dashboard_controller.dart';
import '../models/parent_dashboard_data.dart';
import '../repositories/parent_dashboard_repository.dart';
import 'add_child_screen.dart';
import 'parent_child_details_screen.dart';
import 'task_review_screen.dart';

class ParentDashboardScreen extends StatelessWidget {
  final bool isArabic;

  const ParentDashboardScreen({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ParentDashboardController(ParentDashboardRepository())
            ..loadDashboard(),
      child: _ParentDashboardView(isArabic: isArabic),
    );
  }
}

class _ParentDashboardView extends StatelessWidget {
  final bool isArabic;

  const _ParentDashboardView({required this.isArabic});

  Future<void> _openAddChild(BuildContext context) async {
    final controller = context.read<ParentDashboardController>();

    final wasAdded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) =>  AddChildScreen(isArabic: isArabic,)),
    );

    if (!context.mounted) return;

    if (wasAdded == true) {
      await controller.refresh();
    }
  }

  Future<void> _openTaskReview(BuildContext context) async {
    final controller = context.read<ParentDashboardController>();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) =>  TaskReviewScreen(isArabic: isArabic,)),
    );

    if (!context.mounted) return;

    await controller.refresh();
  }

  Future<void> _openChildDetails(
    BuildContext context,
    ParentDashboardChildItem item,
  ) async {
    final controller = context.read<ParentDashboardController>();

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: ParentChildDetailsScreen(item: item, isArabic: isArabic),
        ),
      ),
    );

    // The controller removes the child from the local dashboard
    // immediately after successful deletion.
    // Therefore, no additional refresh is required here.
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ParentDashboardController>();

    final data = controller.data;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: SafeArea(
            bottom: false,
            child: _buildContent(
              context: context,
              controller: controller,
              data: data,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required ParentDashboardController controller,
    required ParentDashboardData? data,
  }) {
    if (controller.isLoading && data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null) {
      return _DashboardErrorState(
        message:
            controller.errorMessage ??
            (isArabic
                ? 'تعذّر تحميل الصفحة الرئيسية.'
                : 'Could not load the home screen.'),
        isArabic: isArabic,
        onRetry: controller.loadDashboard,
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WelcomeBanner(
              parentName:
                  '${data.user.firstName} '
                  '${data.user.lastName}',
              isArabic: isArabic,
            ),

            const SizedBox(height: AppSpacing.xl),

            if (controller.errorMessage != null)
              _DashboardErrorBanner(
                message: controller.errorMessage!,
                onClose: controller.clearError,
              ),

            _SectionHeader(title: isArabic ? 'أطفالك' : 'Your children'),

            const SizedBox(height: AppSpacing.md),

            if (data.children.isEmpty)
              _NoChildrenState(
                isArabic: isArabic,
                onAddChild: () {
                  _openAddChild(context);
                },
              )
            else ...[
              ...data.children.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SimpleChildCard(
                    item: item,
                    isArabic: isArabic,
                    onTap: () {
                      _openChildDetails(context, item);
                    },
                  ),
                );
              }),

              const SizedBox(height: AppSpacing.sm),

              _AddChildButton(
                isArabic: isArabic,
                onTap: () {
                  _openAddChild(context);
                },
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            _TaskReviewButton(
              count: data.pendingReviewCount,
              isArabic: isArabic,
              onTap: () {
                _openTaskReview(context);
              },
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final String parentName;
  final bool isArabic;

  const _WelcomeBanner({
    required this.parentName,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerWidth = constraints.maxWidth;

        return Container(
          width: double.infinity,
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // الصورة
                Transform.flip(
                  flipX: isArabic,
                  child: Image.asset(
                    'assets/dashboard/family_home.png',
                    fit: BoxFit.cover,
                    alignment: isArabic
    ? Alignment.centerLeft
    : Alignment.centerRight,
                  ),
                ),

                // التدرج الفاتح خلف النص
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      end: isArabic
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      colors: [
                        Colors.white.withOpacity(0.95),
                        const Color(0xFFF4EEF9).withOpacity(0.82),
                       const Color(0xFFE8DDF5).withOpacity(0.38),
                        const Color(0xFFEADDF7).withOpacity(0.08),
                      ],
                      stops: const [
                        0.0,
                        0.30,
                        0.52,
                        0.75,
                      ],
                    ),
                  ),
                ),

                // النص
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Align(
                    alignment: isArabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: SizedBox(
                      width: bannerWidth * 0.44,
                      child: Directionality(
                        textDirection: isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: isArabic
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'مرحبًا' : 'Welcome',
                              textAlign: isArabic
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark.withOpacity(0.75),
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              parentName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: isArabic
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: const TextStyle(
                                fontSize: 21,
                                height: 1.15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),

                            const SizedBox(height: 9),

                            Text(
                              isArabic
                                  ? 'أنتِ تبنين جيلاً رائعًا'
                                  : 'You are building a wonderful generation',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: isArabic
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: const TextStyle(
                                fontSize: 11.5,
                                height: 1.45,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: AppTextStyles.arabicTitle,
    );
  }
}

class _SimpleChildCard extends StatelessWidget {
  final ParentDashboardChildItem item;
  final bool isArabic;
  final VoidCallback onTap;

  const _SimpleChildCard({
    required this.item,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dashboard = item.dashboard;

    final progress = dashboard.progressPercentage.clamp(0, 100).round();

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            // Keep the points badge on the left
            // and progress ring on the right.
            textDirection: TextDirection.ltr,
            children: [
              _ChildPointsBadge(points: item.points, isArabic: isArabic),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      dashboard.childName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      isArabic
                          ? '${dashboard.childAge} سنوات'
                          : '${dashboard.childAge} years old',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              _ProgressRing(percent: progress),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildPointsBadge extends StatelessWidget {
  final int? points;
  final bool isArabic;

  const _ChildPointsBadge({required this.points, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: const BoxDecoration(
        color: AppColors.goldLight,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.gold, size: 15),

          const SizedBox(height: 1),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              points?.toString() ?? '—',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          Text(
            isArabic ? 'نقطة' : 'Points',
            style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int percent;

  const _ProgressRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    final safePercent = percent.clamp(0, 100);

    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: CircularProgressIndicator(
              value: safePercent / 100,
              strokeWidth: 5,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),

          Text(
            '$safePercent%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddChildButton extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onTap;

  const _AddChildButton({required this.isArabic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        // Keep the plus button on the left.
        textDirection: TextDirection.ltr,
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.add, color: Colors.white),
          ),

          Expanded(
            child: Center(
              child: Text(
                isArabic ? 'إضافة طفل' : 'Add child',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _TaskReviewButton extends StatelessWidget {
  final int count;
  final bool isArabic;
  final VoidCallback onTap;

  const _TaskReviewButton({
    required this.count,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              const Icon(Icons.fact_check_outlined, color: AppColors.primary),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Text(
                  isArabic ? 'مراجعة المهام' : 'Review tasks',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              if (count > 0)
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.error,
                  child: Text(
                    '$count',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                )
              else
                Icon(
                  isArabic ? Icons.chevron_left : Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoChildrenState extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onAddChild;

  const _NoChildrenState({required this.isArabic, required this.onAddChild});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.family_restroom_rounded,
            size: 48,
            color: AppColors.primary,
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            isArabic ? 'لا يوجد أطفال بعد' : 'No children added yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          ElevatedButton.icon(
            onPressed: onAddChild,
            icon: const Icon(Icons.add),
            label: Text(isArabic ? 'إضافة طفل' : 'Add child'),
          ),
        ],
      ),
    );
  }
}

class _DashboardErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const _DashboardErrorBanner({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFF9DEDE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 18, color: AppColors.error),
          ),

          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  final String message;
  final bool isArabic;
  final Future<void> Function() onRetry;

  const _DashboardErrorState({
    required this.message,
    required this.isArabic,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: 140),

        const Icon(
          Icons.dashboard_outlined,
          size: 52,
          color: AppColors.primary,
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error),
        ),

        const SizedBox(height: AppSpacing.md),

        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            child: Text(isArabic ? 'إعادة المحاولة' : 'Try again'),
          ),
        ),
      ],
    );
  }
}
