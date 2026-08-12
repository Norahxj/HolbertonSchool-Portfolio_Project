import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/child_model.dart';
import '../../add_task/widgets/child_card.dart';
import '../controllers/weekly_plan_controller.dart';

class WeeklyPlanChildSelection extends StatelessWidget {
  final List<ChildModel> children;

  const WeeklyPlanChildSelection({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WeeklyPlanController>();
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.weeklyPlanChooseChild,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.weeklyPlanChooseChildSubtitle,
          style: const TextStyle(
            fontSize: 12,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (children.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l10n.weeklyPlanNoChildren,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final child in children)
                ChildCard(
                  name: child.name,
                  avatarIndex: child.avatarIndex,
                  isSelected: controller.selectedChildId == child.id,
                  onTap: () {
                    controller.selectChild(child.id);
                  },
                ),
            ],
          ),
      ],
    );
  }
}