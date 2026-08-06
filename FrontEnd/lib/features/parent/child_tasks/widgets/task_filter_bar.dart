import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';

enum ChildTaskFilter {
  all,
  upcoming,
  active,
  awaitingReview,
  completed,
  rejected,
}

class TaskFilterBar extends StatelessWidget {
  final ChildTaskFilter selectedFilter;
  final ValueChanged<ChildTaskFilter> onSelected;

  const TaskFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  String _label(BuildContext context, ChildTaskFilter filter) {
    final l10n = context.l10n;

    switch (filter) {
      case ChildTaskFilter.all:
        return l10n.all;

      case ChildTaskFilter.upcoming:
        return l10n.upcoming;

      case ChildTaskFilter.active:
        return l10n.active;

      case ChildTaskFilter.awaitingReview:
        return l10n.awaitingReview;

      case ChildTaskFilter.completed:
        return l10n.completed;

      case ChildTaskFilter.rejected:
        return l10n.rejected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ChildTaskFilter.values.length,
        separatorBuilder: (_, _) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final filter = ChildTaskFilter.values[index];

          final isSelected = selectedFilter == filter;

          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              onSelected(filter);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 15,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                _label(context, filter),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
