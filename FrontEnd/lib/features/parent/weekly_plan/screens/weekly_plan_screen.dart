import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/child_model.dart';
import '../controllers/weekly_plan_controller.dart';
import '../repositories/weekly_plan_repository.dart';
import '../widgets/weekly_plan_child_selection.dart';
import '../widgets/weekly_plan_generate_button.dart';
import '../widgets/weekly_plan_generating_view.dart';
import '../widgets/weekly_plan_intro_card.dart';
import '../widgets/weekly_plan_message_card.dart';
import '../widgets/weekly_plan_result_view.dart';

class WeeklyPlanScreen extends StatelessWidget {
  final List<ChildModel> children;

  const WeeklyPlanScreen({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeeklyPlanController(
        repository: WeeklyPlanRepository(),
      ),
      child: _WeeklyPlanView(
        children: children,
      ),
    );
  }
}

class _WeeklyPlanView extends StatelessWidget {
  final List<ChildModel> children;

  const _WeeklyPlanView({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        context.watch<WeeklyPlanController>();

    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.weeklyPlanTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const WeeklyPlanIntroCard(),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              if (!controller.hasPlan) ...[
                WeeklyPlanChildSelection(
                  children: children,
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                const WeeklyPlanGenerateButton(),
              ],

              if (controller.isGenerating) ...[
                const SizedBox(
                  height: AppSpacing.xl,
                ),

                const WeeklyPlanGeneratingView(),
              ],

              if (
                controller.errorType != null &&
                !controller.hasPlan
              ) ...[
                const SizedBox(
                  height: AppSpacing.lg,
                ),

                WeeklyPlanErrorCard(
                  message: _errorMessage(
                    context,
                    controller.errorType!,
                  ),
                ),
              ],

              if (
                controller.hasPlan &&
                !controller.isGenerating
              )
                WeeklyPlanResultView(
                  result: controller.result!,
                ),
            ],
          ),
        ),
      ),
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