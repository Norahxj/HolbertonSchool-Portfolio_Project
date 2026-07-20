import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/screen_background.dart';

import '../controllers/add_task_controller.dart';

import 'choose_child_step.dart';
import 'task_details_step.dart';
import 'task_schedule_step.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    super.key,
  });

  @override
  State<AddTaskScreen> createState() =>
      _AddTaskScreenState();
}

class _AddTaskScreenState
    extends State<AddTaskScreen> {
  late final AddTaskController controller;

  int currentStep = 0;
  bool isSaving = false;

 @override
void initState() {
  super.initState();

  controller = AddTaskController();

  controller.loadChildren().then((_) {
    if (mounted) setState(() {});
  });
}  

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  void _nextStep() {
  bool isValid = true;

  switch (currentStep) {
    case 0:
      isValid = controller.validateChildren();

      if (isValid) {
        isValid = controller.validateCategory();
      }
      break;

    case 1:
      isValid = controller.validateDetails();
      break;
  }

  if (!isValid) {
    setState(() {});
    return;
  }

  if (currentStep < 2) {
    setState(() {
      currentStep++;
    });
  }
}

  void _previousStep() {
    if (currentStep == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      currentStep--;
    });
  }

  Future<void> _saveTask() async {
    setState(() {
      isSaving = true;
    });

    try {
      await controller.saveTask();

      if (!mounted) return;

      Navigator.pop(context, true);
    } on DioException catch (error) {
      controller.handleBackendErrors(error);

      if (mounted) {
        setState(() {});
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                _buildHeader(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildCurrentStep(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'إضافة مهمة',
      'تفاصيل المهمة',
      'جدول المهمة',
    ];

    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              titles[currentStep],
              style: AppTextStyles.arabicTitle,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_forward,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return ChooseChildStep(
          children: controller.children,
          selectedChildIds: controller.selectedChildIds,
          selectedCategory: controller.selectedCategory,
          isLoading: controller.isLoadingChildren,
          error: controller.childError,
          suggestions: controller.suggestions,
          categoryError: controller.categoryError,
          isLoadingSuggestions: controller.isLoadingSuggestions,
          onChildSelected: (childId) async {
            await controller.selectChild(childId);

            if (mounted) {
              setState(() {});
              }
          },
           onCategorySelected: (category) async {
            await controller.loadSuggestions(category);
             if (mounted) {
               setState(() {});
             }
           },
          onSuggestionSelected: (suggestion) {
            controller.useSuggestion(
              suggestion,
            );

            setState(() {
              currentStep = 1;
            });
          },
        );

      case 1:
        return TaskDetailsStep(
          nameController:controller.taskNameController,
          descriptionController: controller.taskDescriptionController,
          points: controller.taskPoints,
          trustChild: controller.trustChild,
          titleError: controller.titleError,
          descriptionError: controller.descriptionError,
          pointsError: controller.pointsError,
          onPointsChanged: (value) {
            setState(() {
              controller.taskPoints = value;
            });
          },
          onTrustChanged: (value) {
            setState(() {
              controller.trustChild = value;
            });
          },
        );

      case 2:
        return TaskScheduleStep(
          selectedFrequency:controller.selectedFrequency,
          selectedWeeklyDay:controller.selectedWeeklyDay,
          selectedMonthlyDay:controller.selectedMonthlyDay,
          weekDays:controller.weekDays,
          monthlyDays:controller.monthlyDays,
          frequencyError:controller.frequencyError,
          recurrenceDayError:controller.recurrenceDayError,
          onFrequencyChanged: (value) {
            setState(() {
              controller.selectedFrequency = value;
            });
          },
          onWeeklyDayChanged: (day) {
            setState(() {
              controller.selectedWeeklyDay = day;
            });
          },
          onMonthlyDayChanged: (day) {
            setState(() {
              controller.selectedMonthlyDay = day;
            });
          },
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AppButton(
            text: currentStep == 2
                ? 'حفظ المهمة'
                : 'التالي',
            onPressed: isSaving
                ? null
                : currentStep == 2
                    ? _saveTask
                    : _nextStep,
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
            ),
          ),
        ),
        if (currentStep > 0) ...[
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              child: const Text('رجوع'),
            ),
          ),
        ],
      ],
    );
  }
}