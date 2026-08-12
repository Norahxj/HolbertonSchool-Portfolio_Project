import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../controllers/weekly_plan_controller.dart';
import '../models/weekly_plan_models.dart';
import '../repositories/weekly_plan_repository.dart';
import 'weekly_plan_message_card.dart';
import 'weekly_plan_summary_card.dart';
import 'weekly_plan_task_card.dart';

class WeeklyPlanResultView extends StatelessWidget {
  final WeeklyPlanResult result;

  const WeeklyPlanResultView({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WeeklyPlanController>();
    final l10n = context.l10n;
    final languageCode =
        Localizations.localeOf(context).languageCode;

    final plan = result.plan;

    final summary = languageCode == 'ar'
        ? plan.summaryAr
        : plan.summaryEn;

    final approved =
        result.proposalStatus == 'APPROVED';

    final rejected =
        result.proposalStatus == 'REJECTED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),

        WeeklyPlanSummaryCard(
          summary: summary,
          totalTasks: plan.totalTasks,
          weeklyPoints: plan.weeklyPoints,
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          l10n.weeklyPlanTasks,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        ...plan.tasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.md,
            ),
            child: WeeklyPlanTaskCard(
              task: task,
            ),
          ),
        ),

        if (controller.errorType != null) ...[
          const SizedBox(height: AppSpacing.sm),
          WeeklyPlanErrorCard(
            message: _errorMessage(
              context,
              controller.errorType!,
            ),
          ),
        ],

        if (controller.approvalSucceeded) ...[
          const SizedBox(height: AppSpacing.sm),
          WeeklyPlanSuccessCard(
            message: l10n.weeklyPlanApprovedSuccess,
          ),
        ],

        if (controller.rejectionSucceeded) ...[
          const SizedBox(height: AppSpacing.sm),
          WeeklyPlanSuccessCard(
            message: l10n.weeklyPlanRejectedMessage,
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        if (!approved && !rejected)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: controller.canReject
                        ? () async {
                            final success =
                                await controller.rejectPlan();

                            if (
                              success &&
                              context.mounted
                            ) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n
                                        .weeklyPlanRejectedMessage,
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    icon: controller.isRejecting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.close_rounded,
                          ),
                    label: Text(
                      controller.isRejecting
                          ? l10n.weeklyPlanRejecting
                          : l10n.weeklyPlanReject,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          AppColors.textPrimary,
                      side: const BorderSide(
                        color: AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: controller.canApprove
                        ? () async {
                            final success =
                                await controller.approvePlan(
                              languageCode:
                                  languageCode,
                            );

                            if (
                              success &&
                              context.mounted
                            ) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n
                                        .weeklyPlanApprovedSuccess,
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    icon: controller.isApproving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons
                                .check_circle_outline,
                          ),
                    label: Text(
                      controller.isApproving
                          ? l10n.weeklyPlanApproving
                          : l10n.weeklyPlanApprove,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor:
                          Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else if (approved)
          _StatusMessage(
            icon: Icons.check_circle,
            message: l10n.weeklyPlanApprovedMessage,
          )
        else
          _StatusMessage(
            icon: Icons.cancel_outlined,
            message: l10n.weeklyPlanRejectedMessage,
          ),

        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  String _errorMessage(
    BuildContext context,
    WeeklyPlanErrorType errorType,
  ) {
    final l10n = context.l10n;

    switch (errorType) {
      case WeeklyPlanErrorType.generateFailed:
        return l10n.weeklyPlanGenerateFailed;

      case WeeklyPlanErrorType.approveFailed:
        return l10n.weeklyPlanApproveFailed;

      case WeeklyPlanErrorType.rejectFailed:
        return l10n.weeklyPlanRejectFailed;

      case WeeklyPlanErrorType.serviceUnavailable:
        return l10n.weeklyPlanServiceUnavailable;

      case WeeklyPlanErrorType.noSuitablePlan:
        return l10n.weeklyPlanNoSuitablePlan;
    }
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _StatusMessage({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}