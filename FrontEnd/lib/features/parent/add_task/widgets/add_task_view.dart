import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/screen_background.dart';
import '../../../../models/task_suggestion_model.dart';
import '../controllers/add_task_controller.dart';
import 'add_task_bottom_buttons.dart';
import 'choose_child_step.dart';
import 'task_details_step.dart';

class AddTaskView extends StatelessWidget {
  final ScrollController scrollController;

  final TextEditingController taskNameController;

  final TextEditingController taskDescriptionController;

  final String languageCode;

  final Future<void> Function() onRefresh;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Future<void> Function() onSave;

  final Future<void> Function() onMonthlyDayPicker;

  final ValueChanged<TaskSuggestionModel> onSuggestionTap;

  const AddTaskView({
    super.key,
    required this.scrollController,
    required this.taskNameController,
    required this.taskDescriptionController,
    required this.languageCode,
    required this.onRefresh,
    required this.onNext,
    required this.onBack,
    required this.onSave,
    required this.onMonthlyDayPicker,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

    final l10n = context.l10n;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              controller: scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    controller.currentStep == 0
                        ? l10n.addTask
                        : l10n.taskDetails,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.arabicTitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    controller.currentStep == 0
                        ? l10n.chooseChildSubtitle
                        : l10n.taskDetailsSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (controller.currentStep == 0)
                    ChooseChildStep(
                      languageCode: languageCode,
                      onSuggestionTap: onSuggestionTap,
                    ),
                  if (controller.currentStep == 1)
                    TaskDetailsStep(
                      taskNameController: taskNameController,
                      taskDescriptionController: taskDescriptionController,
                      onMonthlyDayPicker: onMonthlyDayPicker,
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  AddTaskBottomButtons(
                    onNext: onNext,
                    onBack: onBack,
                    onSave: onSave,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
