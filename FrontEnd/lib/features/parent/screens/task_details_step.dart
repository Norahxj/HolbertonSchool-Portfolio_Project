import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import 'package:frontend/features/parent/widgets/task_error_text.dart';
import 'package:frontend/features/parent/widgets/task_text_field.dart';
import 'package:frontend/features/parent/widgets/points_selector.dart';
import 'package:frontend/features/parent/widgets/trust_child_card.dart';  
import 'package:frontend/features/parent/widgets/task_info_box.dart';

class TaskDetailsStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final int points;
  final bool trustChild;

  final String? titleError;
  final String? descriptionError;
  final String? pointsError;

  final ValueChanged<int> onPointsChanged;
  final ValueChanged<bool> onTrustChanged;

  const TaskDetailsStep({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.points,
    required this.trustChild,
    required this.titleError,
    required this.descriptionError,
    required this.pointsError,
    required this.onPointsChanged,
    required this.onTrustChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TaskTextField(
          label: 'اسم المهمة',
          hint: 'مثال: ترتيب سريرك',
          controller: nameController,
          errorText: titleError,
        ),

        const SizedBox(height: AppSpacing.lg),

        TaskTextField(
          label: 'الوصف',
          hint: 'صف المهمة باختصار...',
          controller: descriptionController,
          maxLines: 2,
          errorText: descriptionError,
        ),

        const SizedBox(height: AppSpacing.lg),

        const Text(
          'نقاط نور',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        PointsSelector(
          points: points,
          onIncrease: () {
            onPointsChanged(points + 5);
          },
          onDecrease: () {
            if (points > 0) {
              onPointsChanged(points - 5);
            }
          },
        ),

        if (pointsError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ErrorText(pointsError!),
        ],

        const SizedBox(height: AppSpacing.md),

        const InfoBox(
          text: 'نقاط نور تحفّز الأطفال وتشجعهم على الاستمرار.',
        ),

        const SizedBox(height: AppSpacing.md),

        TrustChildCard(
          value: trustChild,
          onChanged: onTrustChanged,
        ),
      ],
    );
  }
}