import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/parent_dashboard_controller.dart';
import '../models/parent_dashboard_data.dart';
import '../utils/parent_dashboard_localization.dart';
import 'children_section_header.dart';
import 'dashboard_child_card.dart';
import 'dashboard_states.dart';
import 'welcome_banner.dart';

class ParentDashboardView extends StatelessWidget {
  final VoidCallback onAddChild;
  final VoidCallback onReviewTasks;
  final ValueChanged<ParentDashboardChildItem> onChildTap;

  const ParentDashboardView({
    super.key,
    required this.onAddChild,
    required this.onReviewTasks,
    required this.onChildTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ParentDashboardController>();

    final data = controller.data;

    return Scaffold(
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

    final errorMessage =
        controller.backendMessage ?? controller.errorCode?.localized(context);

    if (data == null) {
      return DashboardErrorState(
        message: errorMessage ?? context.l10n.failedToLoadDashboard,
        onRetry: controller.loadDashboard,
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WelcomeBanner(
              parentName:
                  '${data.user.firstName} '
                  '${data.user.lastName}',
            ),
            const SizedBox(height: AppSpacing.xl),
            if (errorMessage != null) ...[
              DashboardErrorBanner(
                message: errorMessage,
                onClose: controller.clearError,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            ChildrenSectionHeader(
              pendingReviewCount: data.pendingReviewCount,
              onAddChild: onAddChild,
              onReviewTasks: onReviewTasks,
            ),
            const SizedBox(height: AppSpacing.md),
            if (data.children.isEmpty)
              DashboardNoChildrenState(onAddChild: onAddChild)
            else
              for (final item in data.children)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: AppSpacing.md,
                  ),
                  child: DashboardChildCard(
                    item: item,
                    onTap: () {
                      onChildTap(item);
                    },
                  ),
                ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
