import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/add_reward_controller.dart';
import 'day_chip.dart';
import 'reward_field_label.dart';
import 'reward_text_field.dart';

class AddRewardView extends StatelessWidget {
  final bool isArabic;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final Future<void> Function() onSave;
  final VoidCallback onBack;

  const AddRewardView({
    super.key,
    required this.isArabic,
    required this.nameController,
    required this.descriptionController,
    required this.onSave,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddRewardController>();

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    isArabic: isArabic,
                    title: controller.text('مكافأة جديدة', 'New Reward'),
                    onBack: onBack,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  RewardFieldLabel(
                    text: controller.text('اسم المكافأة', 'Reward name'),
                    isArabic: isArabic,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  RewardTextField(
                    controller: nameController,
                    isArabic: isArabic,
                    hint: controller.text(
                      'مثال: رحلة إلى الحديقة',
                      'Example: A trip to the park',
                    ),
                    errorText: controller.nameError,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  RewardFieldLabel(
                    text: controller.text('وصف المكافأة', 'Reward description'),
                    isArabic: isArabic,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  RewardTextField(
                    controller: descriptionController,
                    isArabic: isArabic,
                    hint: controller.text(
                      'مثال: زيارة الحديقة مع العائلة في نهاية الأسبوع',
                      'Example: A weekend visit to the park with the family',
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  RewardFieldLabel(
                    text: controller.text(
                      'يوم إتاحة المكافأة',
                      'Reward unlock day',
                    ),
                    isArabic: isArabic,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    alignment: WrapAlignment.start,
                    children: [
                      for (
                        int index = 0;
                        index < controller.weekDays.length;
                        index++
                      )
                        DayChip(
                          label: controller.weekDays[index],
                          isSelected: controller.selectedUnlockDay == index,
                          onTap: () {
                            controller.selectUnlockDay(index);
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
                            controller.text(
                              'ستصبح المكافأة متاحة للطفل يوم '
                                  '${controller.weekDays[controller.selectedUnlockDay]} '
                                  'من كل أسبوع.',
                              'The reward will become available to the child '
                                  'every '
                                  '${controller.weekDays[controller.selectedUnlockDay]}.',
                            ),
                            textAlign: isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
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
                        ? controller.text('جارٍ الحفظ...', 'Saving...')
                        : controller.text('حفظ المكافأة', 'Save Reward'),
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
      ),
    );
  }
}
