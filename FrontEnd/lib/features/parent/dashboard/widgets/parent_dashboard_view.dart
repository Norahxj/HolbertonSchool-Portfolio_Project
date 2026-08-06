import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/screen_background.dart';
import '../../add_child/screens/add_child_screen.dart';
import '../../parent_child_details/screens/parent_child_details_screen.dart';
import '../../task_review/screens/task_review_screen.dart';
import '../controllers/parent_dashboard_controller.dart';
import '../models/parent_dashboard_data.dart';
import '../utils/parent_dashboard_localization.dart';
import 'children_section_header.dart';
import 'dashboard_child_card.dart';
import 'dashboard_states.dart';
import 'welcome_banner.dart';

class ParentDashboardView extends StatelessWidget {
  final VoidCallback onChildrenChanged;

  const ParentDashboardView({
    super.key,
    required this.onChildrenChanged,
  });

  Future<void> _openAddChild(BuildContext context) async {
    final controller = context.read<ParentDashboardController>();

    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    final wasAdded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddChildScreen(
            isArabic: isArabic,
          );
        },
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (wasAdded == true) {
      await controller.refresh();

      if (!context.mounted) {
        return;
      }

      onChildrenChanged();
    }
  }

  Future<void> _openTaskReview(BuildContext context) async {
    final controller = context.read<ParentDashboardController>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return const TaskReviewScreen();
        },
      ),
    );

    if (!context.mounted) {
      return;
    }

    await controller.refresh();
  }

  Future<void> _openChildDetails(
    BuildContext context,
    ParentDashboardChildItem item,
  ) async {
    final controller = context.read<ParentDashboardController>();

    final wasUpdated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChangeNotifierProvider.value(
            value: controller,
            child: ParentChildDetailsScreen(
              item: item,
            ),
          );
        },
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (wasUpdated == true) {
      await controller.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        context.watch<ParentDashboardController>();

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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final errorMessage =
        controller.backendMessage ??
        controller.errorCode?.localized(context);

    if (data == null) {
      return DashboardErrorState(
        message:
            errorMessage ??
            context.l10n.failedToLoadDashboard,
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
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            WelcomeBanner(
              parentName:
                  '${data.user.firstName} '
                  '${data.user.lastName}',
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            if (errorMessage != null)
              DashboardErrorBanner(
                message: errorMessage,
                onClose: controller.clearError,
              ),

            ChildrenSectionHeader(
              pendingReviewCount:
                  data.pendingReviewCount,
              onAddChild: () {
                _openAddChild(context);
              },
              onReviewTasks: () {
                _openTaskReview(context);
              },
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            if (data.children.isEmpty)
              DashboardNoChildrenState(
                onAddChild: () {
                  _openAddChild(context);
                },
              )
            else
              ...data.children.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.md,
                  ),
                  child: DashboardChildCard(
                    item: item,
                    onTap: () {
                      _openChildDetails(
                        context,
                        item,
                      );
                    },
                  ),
                );
              }),

            const SizedBox(
              height: AppSpacing.lg,
            ),
          ],
        ),
      ),
    );
  }
}