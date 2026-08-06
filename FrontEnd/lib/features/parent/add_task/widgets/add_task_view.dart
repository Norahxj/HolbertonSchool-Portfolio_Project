import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/add_task_controller.dart';
import 'add_task_bottom_buttons.dart';
import 'choose_child_step.dart';
import 'task_details_step.dart';

class AddTaskView extends StatelessWidget {
  final bool isArabic;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Future<void> Function() onSave;
  final Future<void> Function() onMonthlyDayPicker;
  final VoidCallback onSuggestionApplied;

  const AddTaskView({
    super.key,
    required this.isArabic,
    required this.scrollController,
    required this.onRefresh,
    required this.onNext,
    required this.onBack,
    required this.onSave,
    required this.onMonthlyDayPicker,
    required this.onSuggestionApplied,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        controller.stepTitle,
                        style: AppTextStyles.arabicTitle,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      controller.stepSubtitle,
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    if (controller.currentStep == 0)
                      ChooseChildStep(
                        isArabic: isArabic,
                        onSuggestionApplied: onSuggestionApplied,
                      ),

                    if (controller.currentStep == 1)
                      TaskDetailsStep(
                        isArabic: isArabic,
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
      ),
    );
  }
}
