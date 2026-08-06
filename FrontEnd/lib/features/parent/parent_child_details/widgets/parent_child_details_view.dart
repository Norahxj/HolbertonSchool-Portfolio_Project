import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/child_avatar.dart';
import '../../../../core/widgets/screen_background.dart';
import '../../../../models/child_model.dart';
import '../controllers/parent_child_details_controller.dart';
import 'child_access_code_card.dart';
import 'child_details_navigation_card.dart';
import 'information_card.dart';

class ParentChildDetailsView extends StatelessWidget {
  final ChildModel child;
  final int? points;
  final int progressPercentage;

  final VoidCallback onBack;
  final VoidCallback onCopyAccessCode;
  final VoidCallback onPointsHistoryTap;
  final VoidCallback onDailyFeedbackTap;
  final VoidCallback onTasksTap;
  final VoidCallback onEditChildTap;
  final VoidCallback onDeleteChildTap;

  const ParentChildDetailsView({
    super.key,
    required this.child,
    required this.points,
    required this.progressPercentage,
    required this.onBack,
    required this.onCopyAccessCode,
    required this.onPointsHistoryTap,
    required this.onDailyFeedbackTap,
    required this.onTasksTap,
    required this.onEditChildTap,
    required this.onDeleteChildTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ParentChildDetailsController>();

    final progress = progressPercentage.clamp(0, 100);

    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: AppPageHeader(title: l10n.childDetails, onBack: onBack),
      ),
      body: ScreenBackground(
        child: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: controller.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ChildAvatar(
                      avatarIndex: child.avatarIndex,
                      size: 92,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    child.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.childAgeYears(child.age),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: InformationCard(
                          icon: Icons.auto_awesome,
                          value: points?.toString() ?? '—',
                          label: l10n.noorPoints,
                          iconColor: AppColors.gold,
                          backgroundColor: AppColors.goldLight,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: InformationCard(
                          icon: Icons.trending_up,
                          value: '$progress%',
                          label: l10n.weeklyProgress,
                          iconColor: AppColors.primary,
                          backgroundColor: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ChildAccessCodeCard(
                    accessCode: child.accessCode,
                    onCopy: onCopyAccessCode,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ChildDetailsNavigationCard(
                    icon: Icons.history,
                    title: l10n.noorPointsHistory,
                    subtitle: l10n.viewPointsHistory,
                    onTap: onPointsHistoryTap,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ChildDetailsNavigationCard(
                    icon: Icons.sentiment_satisfied_alt,
                    title: l10n.dailyFeedback,
                    subtitle: l10n.rateChildDayAndViewHistory(child.name),
                    backgroundColor: Colors.white,
                    onTap: onDailyFeedbackTap,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ChildDetailsNavigationCard(
                    icon: Icons.task_alt_outlined,
                    title: l10n.tasks,
                    subtitle: l10n.viewChildTasks(child.name),
                    onTap: onTasksTap,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextButton.icon(
                    onPressed: controller.isDeletingChild
                        ? null
                        : onEditChildTap,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: 16,
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(
                      l10n.editChildInformation,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: AppSpacing.md),
                  TextButton.icon(
                    onPressed: controller.isDeletingChild
                        ? null
                        : onDeleteChildTap,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: 16,
                      ),
                    ),
                    icon: controller.isDeletingChild
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.error,
                            ),
                          )
                        : const Icon(Icons.delete_outline),
                    label: Text(
                      controller.isDeletingChild
                          ? l10n.deleting
                          : l10n.deleteChild,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
