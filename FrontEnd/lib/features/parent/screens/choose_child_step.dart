import 'package:flutter/material.dart';
import 'package:frontend/models/task_suggestion_model.dart';
import 'package:frontend/core/constants/app_rtl_align.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../models/child_model.dart';
import 'package:frontend/features/parent/widgets/child_card.dart';
import 'package:frontend/features/parent/widgets/task_error_text.dart';
import 'package:frontend/features/parent/widgets/task_info_box.dart';
import 'package:frontend/features/parent/widgets/task_type_card.dart';

class ChooseChildStep extends StatelessWidget {
  final List<ChildModel> children;
  final List<String> selectedChildIds;
  final List<TaskSuggestionModel> suggestions;
  final String? selectedCategory;
  final bool isLoading;
  final bool isLoadingSuggestions;
  final String? error;
  final String? categoryError;
  final ValueChanged<String> onChildSelected;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<TaskSuggestionModel> onSuggestionSelected;

  const ChooseChildStep({
    super.key,
    required this.children,
    required this.selectedChildIds,
    required this.isLoading,
    required this.error,
    required this.categoryError,
    required this.onChildSelected,
    required this.onCategorySelected,
    required this.suggestions,
    required this.isLoadingSuggestions,
    required this.onSuggestionSelected,
    required this.selectedCategory,
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
        
        const RtlAlign(
          child: Text(
          'إضافة سريعة',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ),

        const SizedBox(height: AppSpacing.sm),

         QuickAddCategory(
          icon: Icons.menu_book_outlined,
          label: 'المهام اليومية',
          isSelected: selectedCategory == 'MORAL',
          onTap: () => onCategorySelected('MORAL'),
        ),

        const SizedBox(height: AppSpacing.md),

         QuickAddCategory(
          icon: Icons.groups_outlined,
          label: 'المهام الاجتماعية',
          isSelected: selectedCategory == 'SOCIAL',
          onTap: () => onCategorySelected('SOCIAL'),

        ),

        const SizedBox(height: AppSpacing.md),

         QuickAddCategory(
          icon: Icons.credit_card,
          label: 'المهام المالية',
          isSelected: selectedCategory == 'FINANCIAL',
          onTap: () => onCategorySelected('FINANCIAL'),
        ),

        const SizedBox(height: AppSpacing.md),

         QuickAddCategory(
          icon: Icons.mosque_outlined,
          label: 'المهام الدينية',
          isSelected: selectedCategory == 'RELIGIOUS',
          onTap: () => onCategorySelected('RELIGIOUS'),
        ),
        if (categoryError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ErrorText(categoryError!),
          ],
          
          const SizedBox(height: AppSpacing.xl),

        if (isLoadingSuggestions)
          const Center(
            child: CircularProgressIndicator(),
          ),

        if (!isLoadingSuggestions &&
            selectedCategory != null &&
            suggestions.isNotEmpty) ...[
          const RtlAlign(
            child: Text(
            'المقترحات',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          ),

          const SizedBox(height: AppSpacing.md),

          ...suggestions.map(
                        (suggestion) => Card(
              margin: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: InkWell(
                onTap: () => onSuggestionSelected(suggestion),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Text(
                        '${suggestion.points} نقطة',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            
                      const SizedBox(width: AppSpacing.md),
            
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              suggestion.title,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
            
                            const SizedBox(height: 4),
            
                            Text(
                              suggestion.description,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],

        if (!isLoadingSuggestions &&
            selectedCategory != null &&
            suggestions.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.md),
            child: Center(
              child: Text(
                'اختر طفل اولا ثم اختر فئة لرؤية المقترحات.',
              ),
            ),
          ),
      ],
    );
  }
}