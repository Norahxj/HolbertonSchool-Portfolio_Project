import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../models/child_model.dart';
import '../controllers/weekly_plan_controller.dart';
import '../models/weekly_plan_models.dart';
import '../repositories/weekly_plan_repository.dart';


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
    final controller = context.watch<WeeklyPlanController>();

    final languageCode = (
      Localizations.localeOf(context).languageCode
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          languageCode == 'ar'
              ? 'الخطة الأسبوعية الذكية'
              : 'Smart Weekly Plan',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _IntroCard(
                languageCode: languageCode,
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              if (!controller.hasPlan) ...[
                _ChildSelectionSection(
                  children: children,
                  languageCode: languageCode,
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _GenerateButton(
                  languageCode: languageCode,
                ),
              ],

              if (
                controller.isGenerating
              ) ...[
                const SizedBox(
                  height: AppSpacing.xl,
                ),
                const _GeneratingView(),
              ],

              if (
                controller.errorMessage != null
              ) ...[
                const SizedBox(
                  height: AppSpacing.lg,
                ),
                _ErrorCard(
                  message: controller.errorMessage!,
                ),
              ],

              if (
                controller.hasPlan
                && !controller.isGenerating
              ) ...[
                _PlanResultView(
                  result: controller.result!,
                  languageCode: languageCode,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


class _ChildSelectionSection extends StatelessWidget {
  final List<ChildModel> children;
  final String languageCode;

  const _ChildSelectionSection({
    required this.children,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WeeklyPlanController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          languageCode == 'ar'
              ? 'اختر الطفل'
              : 'Choose a child',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        Text(
          languageCode == 'ar'
              ? 'سنستخدم سجل المهام والنقاط والأمنيات لبناء خطة مناسبة له.'
              : 'We will use task history, points, and wishes to build a suitable plan.',
          style: const TextStyle(
            fontSize: 12,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        if (children.isEmpty)
          _EmptyChildrenCard(
            languageCode: languageCode,
          )
        else
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final child in children)
                _WeeklyPlanChildCard(
                  child: child,
                  isSelected: (
                    controller.selectedChildId
                    == child.id
                  ),
                  onTap: () {
                    controller.selectChild(
                      child.id,
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }
}


class _GenerateButton extends StatelessWidget {
  final String languageCode;

  const _GenerateButton({
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WeeklyPlanController>();

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
              ? (
                  languageCode == 'ar'
                      ? 'جاري إنشاء الخطة...'
                      : 'Generating plan...'
                )
              : (
                  languageCode == 'ar'
                      ? 'إنشاء الخطة الأسبوعية'
                      : 'Generate weekly plan'
                ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: (
            AppColors.primary.withValues(
              alpha: 0.25,
            )
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),
    );
  }
}


class _GeneratingView extends StatelessWidget {
  const _GeneratingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(),

          SizedBox(
            height: AppSpacing.md,
          ),

          Text(
            'نحلل أداء الطفل ونبني الخطة المناسبة...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


class _PlanResultView extends StatelessWidget {
  final WeeklyPlanResult result;
  final String languageCode;

  const _PlanResultView({
    required this.result,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WeeklyPlanController>();

    final plan = result.plan;

    final summary = languageCode == 'ar'
        ? plan.summaryAr
        : plan.summaryEn;

    final approved = (
      result.proposalStatus == 'APPROVED'
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: AppSpacing.lg,
        ),

        _PlanSummaryCard(
          summary: summary,
          totalTasks: plan.totalTasks,
          weeklyPoints: plan.weeklyPoints,
          languageCode: languageCode,
        ),

        const SizedBox(
          height: AppSpacing.lg,
        ),

        Text(
          languageCode == 'ar'
              ? 'مهام الأسبوع'
              : 'Weekly tasks',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        ...plan.tasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.md,
            ),
            child: _PlanTaskCard(
              task: task,
              languageCode: languageCode,
            ),
          ),
        ),

        if (
          controller.errorMessage != null
        ) ...[
          const SizedBox(
            height: AppSpacing.sm,
          ),
          _ErrorCard(
            message: controller.errorMessage!,
          ),
        ],

        if (
          controller.successMessage != null
        ) ...[
          const SizedBox(
            height: AppSpacing.sm,
          ),
          _SuccessCard(
            message: languageCode == 'ar'
                ? 'تم اعتماد الخطة وإضافة المهام للطفل بنجاح.'
                : controller.successMessage!,
          ),
        ],

        const SizedBox(
          height: AppSpacing.lg,
        ),

        if (!approved)
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: controller.canApprove
                  ? () async {
                      final success = await controller.approvePlan(
                        languageCode: languageCode,
                      );

                      if (
                        success
                        && context.mounted
                      ) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              languageCode == 'ar'
                                  ? 'تم اعتماد الخطة وإضافة المهام.'
                                  : 'Plan approved and tasks added.',
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.check_circle_outline,
                    ),
              label: Text(
                controller.isApproving
                    ? (
                        languageCode == 'ar'
                            ? 'جاري اعتماد الخطة...'
                            : 'Approving plan...'
                      )
                    : (
                        languageCode == 'ar'
                            ? 'اعتماد الخطة'
                            : 'Approve plan'
                      ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(
                16,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Expanded(
                  child: Text(
                    languageCode == 'ar'
                        ? 'تم اعتماد هذه الخطة وإضافة المهام للطفل.'
                        : 'This plan has been approved and its tasks were added.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(
          height: AppSpacing.md,
        ),
      ],
    );
  }
}


class _PlanSummaryCard extends StatelessWidget {
  final String summary;
  final int totalTasks;
  final int weeklyPoints;
  final String languageCode;

  const _PlanSummaryCard({
    required this.summary,
    required this.totalTasks,
    required this.weeklyPoints,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Expanded(
                child: Text(
                  languageCode == 'ar'
                      ? 'الخطة المقترحة'
                      : 'Suggested plan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Text(
            summary,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.task_alt,
                  value: '$totalTasks',
                  label: languageCode == 'ar'
                      ? 'مهام'
                      : 'Tasks',
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Expanded(
                child: _SummaryMetric(
                  icon: Icons.stars_rounded,
                  value: '$weeklyPoints',
                  label: languageCode == 'ar'
                      ? 'نقطة أسبوعية'
                      : 'Weekly points',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),

          const SizedBox(
            height: AppSpacing.xs,
          ),

          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


class _PlanTaskCard extends StatelessWidget {
  final WeeklyPlanTask task;
  final String languageCode;

  const _PlanTaskCard({
    required this.task,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final title = task.titleFor(
      languageCode,
    );

    final description = task.descriptionFor(
      languageCode,
    );

    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          18,
        ),
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

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
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

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _TaskTag(
                label: _categoryLabel(
                  task.category,
                  languageCode,
                ),
              ),

              _TaskTag(
                label: _frequencyLabel(
                  task.frequency,
                  languageCode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _categoryLabel(
    String category,
    String languageCode,
  ) {
    if (languageCode != 'ar') {
      return category;
    }

    switch (category) {
      case 'RELIGIOUS':
        return 'ديني';
      case 'FINANCIAL':
        return 'مالي';
      case 'MORAL':
        return 'سلوكي';
      case 'SOCIAL':
        return 'اجتماعي';
      default:
        return category;
    }
  }

  static String _frequencyLabel(
    String frequency,
    String languageCode,
  ) {
    if (languageCode != 'ar') {
      switch (frequency) {
        case 'DAILY':
          return 'Daily';
        case 'WEEKLY':
          return 'Weekly';
        case 'MONTHLY':
          return 'Monthly';
        default:
          return 'Once';
      }
    }

    switch (frequency) {
      case 'DAILY':
        return 'يومي';
      case 'WEEKLY':
        return 'أسبوعي';
      case 'MONTHLY':
        return 'شهري';
      default:
        return 'مرة واحدة';
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
        borderRadius: BorderRadius.circular(
          20,
        ),
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


class _IntroCard extends StatelessWidget {
  final String languageCode;

  const _IntroCard({
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.smart_toy_outlined,
            size: 34,
            color: AppColors.primary,
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Text(
              languageCode == 'ar'
                  ? 'اختر طفلك وسنقترح له خطة أسبوعية متوازنة ومناسبة لأدائه.'
                  : 'Choose your child and we will suggest a balanced weekly plan based on their progress.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _WeeklyPlanChildCard extends StatelessWidget {
  final ChildModel child;
  final bool isSelected;
  final VoidCallback onTap;

  const _WeeklyPlanChildCard({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        16,
      ),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight
              : Colors.white,
          borderRadius: BorderRadius.circular(
            16,
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                child.name.isNotEmpty
                    ? child.name[0]
                    : '?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              child.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            if (isSelected) ...[
              const SizedBox(
                height: AppSpacing.xs,
              ),
              const Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class _EmptyChildrenCard extends StatelessWidget {
  final String languageCode;

  const _EmptyChildrenCard({
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: Text(
        languageCode == 'ar'
            ? 'لا يوجد أطفال حاليًا.'
            : 'No children yet.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}


class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.error,
        ),
      ),
    );
  }
}


class _SuccessCard extends StatelessWidget {
  final String message;

  const _SuccessCard({
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
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.primary,
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}