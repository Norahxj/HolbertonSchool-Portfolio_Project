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
import '../../../core/widgets/child_avatar.dart';

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
      MaterialPageRoute(builder: (_) => AddChildScreen(isArabic: isArabic)),
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
      MaterialPageRoute(builder: (_) => TaskReviewScreen(isArabic: isArabic)),
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
              parentName: '${data.user.firstName} ${data.user.lastName}',
              isArabic: isArabic,
            ),

            const SizedBox(height: AppSpacing.xl),

            if (controller.errorMessage != null)
              _DashboardErrorBanner(
                message: controller.errorMessage!,
                onClose: controller.clearError,
              ),

          _SectionHeader(
  title: isArabic ? 'أطفالك' : 'Your children',
  isArabic: isArabic,
  pendingReviewCount: data.pendingReviewCount,
  onAddChild: () {
    _openAddChild(context);
  },
  onReviewTasks: () {
    _openTaskReview(context);
  },
),

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
],
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

  const _WelcomeBanner({required this.parentName, required this.isArabic});

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
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.06),
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
                        const Color(0xFFF7F2FB).withValues(alpha:0.78),
                        const Color(0xFFF1E8F8).withValues(alpha:0.55),
                        const Color(0xFFE7DAF5).withValues(alpha:0.18),
                        const Color(0xFFF2ECF8).withValues(alpha:0.18),
                      ],
                      stops: const [0.0, 0.30, 0.52, 0.75],
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  bottom: 0,
                  right: isArabic ? 24 : null,
                  left: isArabic ? null : 24,
                  width: bannerWidth * 0.44,
                  child: Directionality(
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'مرحبًا' : 'Welcome',
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark.withValues(alpha:0.75),
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
  final bool isArabic;
  final int pendingReviewCount;
  final VoidCallback onAddChild;
  final VoidCallback onReviewTasks;

  const _SectionHeader({
    required this.title,
    required this.isArabic,
    required this.pendingReviewCount,
    required this.onAddChild,
    required this.onReviewTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.arabicTitle,
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderActionButton(
              tooltip: isArabic ? 'إضافة طفل' : 'Add child',
              icon: Icons.add_rounded,
              onTap: onAddChild,
            ),

            const SizedBox(width: AppSpacing.sm),

            _ReviewTasksHeaderButton(
              isArabic: isArabic,
              count: pendingReviewCount,
              onTap: onReviewTasks,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primaryLight,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewTasksHeaderButton extends StatelessWidget {
  final bool isArabic;
  final int count;
  final VoidCallback onTap;

  const _ReviewTasksHeaderButton({
    required this.isArabic,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isArabic ? 'مراجعة المهام' : 'Review tasks',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: AppColors.primaryLight,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.fact_check_outlined,
                  size: 23,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          if (count > 0)
            Positioned(
              top: -2,
              right: isArabic ? null : -2,
              left: isArabic ? -2 : null,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
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

    final progress = dashboard.progressPercentage
        .clamp(0, 100)
        .round();

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          constraints: const BoxConstraints(minHeight: 108),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            textDirection:
                isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // العربي: يظهر يمين الكارد.
              // الإنجليزي: يظهر يسار الكارد.
              ChildAvatar(
                avatarIndex: item.child.avatarIndex,
                size: 64,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dashboard.childName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isArabic
                          ? '${dashboard.childAge} سنوات'
                          : '${dashboard.childAge} years old',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    _ChildPointsBadge(
                      points: item.points,
                      isArabic: isArabic,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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

  const _ChildPointsBadge({
    required this.points,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final pointsText = points?.toString() ?? '0';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Icon(
      Icons.auto_awesome_rounded,
      color: AppColors.gold,
      size: 14,
    ),

    const SizedBox(width: 5),

    Text(
      isArabic
          ? '$pointsText نقطة'
          : '$pointsText points',
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
  ],
),
    );
  }
}
class _ProgressRing extends StatelessWidget {
  final int percent;

  const _ProgressRing({
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final safePercent = percent.clamp(0, 100);

    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: safePercent / 100,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          Text(
            '$safePercent%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
/// The same compact button is used in both dashboard states.
class _AddChildButton extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onTap;

  const _AddChildButton({required this.isArabic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          isArabic ? 'إضافة طفل' : 'Add child',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const StadiumBorder(),
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

          _AddChildButton(isArabic: isArabic, onTap: onAddChild),
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
