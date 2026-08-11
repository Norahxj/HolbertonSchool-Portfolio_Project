import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/task_suggestion_model.dart';
import '../../weekly_plan/screens/weekly_plan_screen.dart';
import '../../weekly_plan/widgets/weekly_plan_ai_card.dart';
import '../controllers/add_task_controller.dart';
import '../utils/add_task_localization.dart';
import 'child_card.dart';
import 'quick_add_category.dart';
import 'task_type_section.dart';


class ChooseChildStep extends StatelessWidget {
  final String languageCode;
  final ValueChanged<TaskSuggestionModel> onSuggestionTap;

  const ChooseChildStep({
    super.key,
    required this.languageCode,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeeklyPlanAiCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WeeklyPlanScreen(
                  children: controller.children,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        if (controller.isLoadingChildren)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (controller.children.isEmpty)
          Center(
            child: Text(
              l10n.noChildrenYet,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final child in controller.children)
                ChildCard(
                  name: child.name,
                  avatarIndex: child.avatarIndex,
                  isSelected: controller.selectedChildIds.contains(
                    child.id,
                  ),
                  onTap: () {
                    controller.toggleChild(
                      childId: child.id,
                      languageCode: languageCode,
                    );
                  },
                ),
            ],
          ),

        if (controller.childError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            controller.childError!.localized(context),
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        Text(
          l10n.taskType,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          controller.selectedChildIds.isEmpty
              ? l10n.selectChildFirst
              : l10n.chooseTaskType,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 12,
            color: controller.selectedChildIds.isEmpty
                ? Colors.grey.shade500
                : AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        TaskTypeSection(
          languageCode: languageCode,
        ),

        const SizedBox(height: AppSpacing.xl),

        _TaskInformationBox(
          text: l10n.tasksInformation,
        ),

        const SizedBox(height: AppSpacing.lg),

        if (controller.selectedTaskType != null) ...[
          Text(
            l10n.quickAdd,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          if (controller.isLoadingSuggestions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(
                  AppSpacing.md,
                ),
                child: CircularProgressIndicator(),
              ),
            )
          else if (controller.hasSuggestionsError)
            Column(
              children: [
                Text(
                  controller.suggestionsBackendMessage ??
                      l10n.unableToLoadSuggestions,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.loadTaskSuggestions(
                      languageCode: languageCode,
                    );
                  },
                  child: Text(
                    l10n.retry,
                  ),
                ),
              ],
            )
          else
            QuickAddCategory(
              icon: TaskTypeSection.taskTypeIcon(
                controller.selectedTaskType!,
              ),
              label: TaskTypeSection.taskTypeLabel(
                context,
                controller.selectedTaskType!,
              ),
              suggestions: controller.taskSuggestions,
              onSuggestionTap: onSuggestionTap,
            ),
        ],
      ],
    );
  }
}


class _TaskInformationBox extends StatelessWidget {
  final String text;

  const _TaskInformationBox({
    required this.text,
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
          16,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.start,
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