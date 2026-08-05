import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

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
  final bool isArabic;
  final ValueChanged<ChildTaskFilter> onSelected;

  const TaskFilterBar({
    super.key,
    required this.selectedFilter,
    required this.isArabic,
    required this.onSelected,
  });

  String _label(ChildTaskFilter filter) {
    switch (filter) {
      case ChildTaskFilter.all:
        return isArabic ? 'الكل' : 'All';

      case ChildTaskFilter.upcoming:
        return isArabic ? 'قادمة' : 'Upcoming';

      case ChildTaskFilter.active:
        return isArabic ? 'نشطة' : 'Active';

      case ChildTaskFilter.awaitingReview:
        return isArabic ? 'بانتظار المراجعة' : 'Awaiting review';

      case ChildTaskFilter.completed:
        return isArabic ? 'مكتملة' : 'Completed';

      case ChildTaskFilter.rejected:
        return isArabic ? 'مرفوضة' : 'Rejected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ChildTaskFilter.values.length,
        separatorBuilder: (context, index) {
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
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                _label(filter),
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
