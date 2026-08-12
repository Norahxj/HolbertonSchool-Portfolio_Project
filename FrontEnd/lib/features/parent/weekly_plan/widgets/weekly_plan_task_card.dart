import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../models/weekly_plan_models.dart';

class WeeklyPlanTaskCard extends StatelessWidget {
  final WeeklyPlanTask task;

  const WeeklyPlanTaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;

    final title = task.titleFor(languageCode);
    final description = task.descriptionFor(languageCode);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${task.points} ⭐',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _TaskTag(
                label: _categoryLabel(
                  task.category,
                  l10n,
                ),
              ),
              _TaskTag(
                label: _frequencyLabel(
                  task.frequency,
                  l10n,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryLabel(
    String category,
    dynamic l10n,
  ) {
    switch (category) {
      case 'RELIGIOUS':
        return l10n.weeklyPlanCategoryReligious;
      case 'FINANCIAL':
        return l10n.weeklyPlanCategoryFinancial;
      case 'MORAL':
        return l10n.weeklyPlanCategoryMoral;
      case 'SOCIAL':
        return l10n.weeklyPlanCategorySocial;
      default:
        return category;
    }
  }

  String _frequencyLabel(
    String frequency,
    dynamic l10n,
  ) {
    switch (frequency) {
      case 'DAILY':
        return l10n.weeklyPlanFrequencyDaily;
      case 'WEEKLY':
        return l10n.weeklyPlanFrequencyWeekly;
      case 'MONTHLY':
        return l10n.weeklyPlanFrequencyMonthly;
      default:
        return l10n.weeklyPlanFrequencyOnce;
    }
  }
}

class _TaskTag extends StatelessWidget {
  final String label;

  const _TaskTag({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}