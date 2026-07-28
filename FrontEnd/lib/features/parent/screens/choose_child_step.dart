import 'package:flutter/material.dart';
import 'package:frontend/models/task_suggestion_model.dart';
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
  final bool isArabic;

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
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (children.isEmpty) {
      return Center(
        child: Text(
          isArabic
              ? 'لا يوجد أطفال بعد. الرجاء إضافة طفل أولاً.'
              : 'No children yet. Please add a child first.',
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

        InfoBox(
          text: isArabic
              ? 'المهام تساعد الأطفال على بناء العادات والقيم وكسب نقاط نور.'
              : 'Tasks help children build habits and values while earning Noor points.',
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          isArabic ? 'إضافة سريعة' : 'Quick Add',
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        QuickAddCategory(
          icon: Icons.menu_book_outlined,
          label: isArabic ? 'المهام اليومية' : 'Daily Tasks',
          isSelected: selectedCategory == 'MORAL',
          onTap: () => onCategorySelected('MORAL'),
        ),

        const SizedBox(height: AppSpacing.md),

        QuickAddCategory(
          icon: Icons.groups_outlined,
          label: isArabic ? 'المهام الاجتماعية' : 'Social Tasks',
          isSelected: selectedCategory == 'SOCIAL',
          onTap: () => onCategorySelected('SOCIAL'),
        ),

        const SizedBox(height: AppSpacing.md),

        QuickAddCategory(
          icon: Icons.credit_card,
          label: isArabic ? 'المهام المالية' : 'Financial Tasks',
          isSelected: selectedCategory == 'FINANCIAL',
          onTap: () => onCategorySelected('FINANCIAL'),
        ),

        const SizedBox(height: AppSpacing.md),

        QuickAddCategory(
          icon: Icons.mosque_outlined,
          label: isArabic ? 'المهام الدينية' : 'Religious Tasks',
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
          Text(
            isArabic ? 'المقترحات' : 'Suggestions',
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          ...suggestions.map(
            (suggestion) => Card(
              margin: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: ListTile(
                title: Text(suggestion.title),
                subtitle: Text(suggestion.description),
                trailing: Text(
                  isArabic
                      ? '${suggestion.points} نقطة'
                      : '${suggestion.points} points',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => onSuggestionSelected(suggestion),
              ),
            ),
          ),
        ],

        if (!isLoadingSuggestions &&
            selectedCategory != null &&
            suggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Center(
              child: Text(
                isArabic
                    ? 'اختر طفلًا أولًا ثم اختر فئة لرؤية المقترحات.'
                    : 'Select a child first, then choose a category to view suggestions.',
              ),
            ),
          ),
      ],
    );
  }
}