import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import '../dashboard/widgets/dashboard_child_card.dart';
import '../dashboard/widgets/dashboard_states.dart';

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
      return DashboardErrorState(
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
              DashboardErrorBanner(
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
              DashboardNoChildrenState(
                isArabic: isArabic,
                onAddChild: () {
                  _openAddChild(context);
                },
              )
            else ...[
              ...data.children.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: DashboardChildCard(
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
