import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import 'package:frontend/features/parent/widgets/task_type_card.dart';
import 'package:frontend/features/parent/widgets/task_error_text.dart'; 

class TaskTypeStep extends StatelessWidget {
  final int? selectedType;
  final String? error;
  final ValueChanged<int> onSelected;

  const TaskTypeStep({
    super.key,
    required this.selectedType,
    required this.error,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      (Icons.mosque_outlined, 'المهام الثقافية'),
      (Icons.shopping_bag_outlined, 'المهام اليومية'),
      (Icons.menu_book_outlined, 'المهام الدينية'),
      (Icons.credit_card, 'المهام المالية'),
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: types.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final type = types[index];

            return TaskTypeCard(
              icon: type.$1,
              label: type.$2,
              isSelected: selectedType == index,
              onTap: () => onSelected(index),
            );
          },
        ),

        if (error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ErrorText(error!),
        ],
      ],
    );
  }
}