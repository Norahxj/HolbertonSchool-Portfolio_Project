import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../controllers/weekly_plan_controller.dart';

class WeeklyPlanGenerateButton extends StatelessWidget {
  const WeeklyPlanGenerateButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WeeklyPlanController>();
    final l10n = context.l10n;

    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: controller.canGenerate
            ? () {
                controller.generatePlan();
              }
            : null,
        icon: controller.isGenerating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.auto_awesome,
              ),
        label: Text(
          controller.isGenerating
              ? l10n.weeklyPlanGenerating
              : l10n.weeklyPlanGenerate,
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(
            alpha: 0.25,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}