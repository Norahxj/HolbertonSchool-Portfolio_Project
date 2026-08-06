import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/add_task_controller.dart';

class AddTaskBottomButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Future<void> Function() onSave;

  const AddTaskBottomButtons({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();
    final l10n = context.l10n;

    if (controller.currentStep == 0) {
      return AppButton(
        text: l10n.next,
        onPressed: onNext,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AppButton(
            text: controller.isSaving
                ? l10n.saving
                : l10n.saveTask,
            onPressed: controller.isSaving
                ? null
                : onSave,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
              ),
              child: Text(
                l10n.back,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}