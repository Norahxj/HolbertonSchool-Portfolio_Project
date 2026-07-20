import 'package:flutter/material.dart';
import 'package:frontend/models/task_suggestion_model.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../models/child_model.dart';
import 'package:frontend/features/parent/widgets/child_card.dart';
import 'package:frontend/features/parent/widgets/task_error_text.dart';
import 'package:frontend/features/parent/widgets/task_info_box.dart';
import 'package:frontend/features/parent/widgets/task_type_card.dart';
import '';

class ChooseChildStep extends StatelessWidget {
  final List<ChildModel> children;
  final List<String> selectedChildIds;
  final List<TaskSuggestionModel> suggestions;
  final bool isLoading;
  final bool isLoadingSuggestions;
  final String? error;
  final ValueChanged<String> onChildSelected;
  final ValueChanged<TaskSuggestionModel> onSuggestionSelected;

  const ChooseChildStep({
    super.key,
    required this.children,
    required this.selectedChildIds,
    required this.isLoading,
    required this.error,
    required this.onChildSelected,
    required this.suggestions,
    required this.isLoadingSuggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (children.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد أطفال بعد. الرجاء إضافة طفل أولاً.',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: children.map((child) {
            final selected = selectedChildIds.contains(child.id);

            return ChildCard(
              name: child.name,
              isSelected: selected,
              onTap: () => onChildSelected(child.id),
            );
          }).toList(),
        ),

        if (error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ErrorText(error!),
        ],

        const SizedBox(height: AppSpacing.lg),

        const InfoBox(
          text:
              'المهام تساعد الأطفال على بناء العادات والقيم وكسب نقاط نور.',
        ),
        
        const SizedBox(height: AppSpacing.lg),

        const Text(
          'إضافة سريعة',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        const QuickAddCategory(
          icon: Icons.shopping_bag_outlined,
          label: 'المهام اليومية',
        ),

        const SizedBox(height: AppSpacing.md),

        const QuickAddCategory(
          icon: Icons.mosque_outlined,
          label: 'المهام الثقافية',
        ),

        const SizedBox(height: AppSpacing.md),

        const QuickAddCategory(
          icon: Icons.credit_card,
          label: 'المهام المالية',
        ),

        const SizedBox(height: AppSpacing.md),

        const QuickAddCategory(
          icon: Icons.menu_book_outlined,
          label: 'المهام الدينية',
        ),
      ],
    );
  }
}