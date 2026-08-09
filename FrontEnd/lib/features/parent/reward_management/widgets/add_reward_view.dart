import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_field_label.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_selectable_chip.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/add_reward_controller.dart';
import '../utils/add_reward_localization.dart';
import 'reward_text_field.dart';

class AddRewardView extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final Future<void> Function() onSave;
  final VoidCallback onBack;

  const AddRewardView({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.onSave,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddRewardController>();
    final l10n = context.l10n;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: l10n.newReward,
                  onBack: onBack,
                ),

                const SizedBox(height: AppSpacing.xl),

                AppFieldLabel(
                  text: l10n.rewardName,
                ),

                const SizedBox(height: AppSpacing.sm),

                RewardTextField(
                  controller: nameController,
                  hint: l10n.rewardNameExample,
                  errorText: controller.nameError?.localized(context),
                ),

                const SizedBox(height: AppSpacing.lg),

                AppFieldLabel(
                  text: l10n.rewardDescription,
                ),

                const SizedBox(height: AppSpacing.sm),

                RewardTextField(
                  controller: descriptionController,
                  hint: l10n.rewardDescriptionExample,
                  maxLines: 3,
                ),

                const SizedBox(height: AppSpacing.lg),

                AppFieldLabel(
                  text: l10n.rewardUnlockDayLabel,
                ),

                const SizedBox(height: AppSpacing.sm),

                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.start,
                  children: [
                    for (final dayIndex in controller.weekDays)
                      AppSelectableChip(
                        label: _dayLabel(context, dayIndex),
                        isSelected:
                            controller.selectedUnlockDay == dayIndex,
                        onTap: () {
                          controller.selectUnlockDay(dayIndex);
                        },
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.primary,
                        size: 19,
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      Expanded(
                        child: Text(
                          l10n.rewardAvailableEveryWeek(
                            _dayLabel(
                              context,
                              controller.selectedUnlockDay,
                            ),
                          ),
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  text: controller.isSaving
                      ? l10n.saving
                      : l10n.saveReward,
                  onPressed: controller.isSaving ? null : onSave,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.primaryGradient,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _dayLabel(
    BuildContext context,
    int dayIndex,
  ) {
    final l10n = context.l10n;

    switch (dayIndex) {
      case 0:
        return l10n.sunday;
      case 1:
        return l10n.monday;
      case 2:
        return l10n.tuesday;
      case 3:
        return l10n.wednesday;
      case 4:
        return l10n.thursday;
      case 5:
        return l10n.friday;
      case 6:
        return l10n.saturday;
      default:
        return '';
    }
  }
}