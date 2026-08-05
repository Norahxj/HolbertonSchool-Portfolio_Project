import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/screen_background.dart';
import '../controllers/parent_dashboard_controller.dart';
import '../models/parent_dashboard_data.dart';
import '../repositories/parent_dashboard_repository.dart';
import 'add_child_screen.dart';
import 'parent_child_details_screen.dart';
import 'task_review_screen.dart';
import '../dashboard/widgets/welcome_banner.dart';
import '../dashboard/widgets/children_section_header.dart';
import '../dashboard/widgets/child_card.dart';

class ParentDashboardScreen extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onChildrenChanged;

  const ParentDashboardScreen({
    super.key,
    required this.isArabic,
    required this.onChildrenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ParentDashboardController(ParentDashboardRepository())
            ..loadDashboard(),
      child: _ParentDashboardView(
        isArabic: isArabic,
        onChildrenChanged: onChildrenChanged,
      ),
    );
  }
}

class _ParentDashboardView extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onChildrenChanged;

  const _ParentDashboardView({
    required this.isArabic,
    required this.onChildrenChanged,
  });

  Future<void> _openAddChild(BuildContext context) async {
    final controller = context.read<ParentDashboardController>();

    final wasAdded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddChildScreen(isArabic: isArabic)),
    );

    if (!context.mounted) return;

    if (wasAdded == true) {
      await controller.refresh();
      onChildrenChanged();
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
            WelcomeBanner(
              parentName: '${data.user.firstName} ${data.user.lastName}',
              isArabic: isArabic,
            ),

            const SizedBox(height: AppSpacing.xl),

            if (controller.errorMessage != null)
              _DashboardErrorBanner(
                message: controller.errorMessage!,
                onClose: controller.clearError,
              ),

            ChildrenSectionHeader(
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
                  child: ChildCard(
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
