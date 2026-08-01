import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/task_assignment_model.dart';
import '../controllers/parent_child_details_controller.dart';

enum ChildTaskFilter { all, active, awaitingReview, completed, rejected }

class ChildTasksScreen extends StatelessWidget {
  final String childId;
  final String childName;
  final bool isArabic;
  final ParentChildDetailsController controller;

  const ChildTasksScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.isArabic,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: _ChildTasksView(
        childId: childId,
        childName: childName,
        isArabic: isArabic,
      ),
    );
  }
}

class _ChildTasksView extends StatefulWidget {
  final String childId;
  final String childName;
  final bool isArabic;

  const _ChildTasksView({
    required this.childId,
    required this.childName,
    required this.isArabic,
  });

  @override
  State<_ChildTasksView> createState() => _ChildTasksViewState();
}

class _ChildTasksViewState extends State<_ChildTasksView> {
  ChildTaskFilter selectedFilter = ChildTaskFilter.all;

  List<TaskAssignmentModel> _filteredTasks(List<TaskAssignmentModel> tasks) {
    switch (selectedFilter) {
      case ChildTaskFilter.all:
        return tasks;

      case ChildTaskFilter.active:
        return tasks.where((task) => task.isPending).toList();

      case ChildTaskFilter.awaitingReview:
        return tasks.where((task) => task.needsParentApproval).toList();

      case ChildTaskFilter.completed:
        return tasks.where((task) => task.isApproved).toList();

      case ChildTaskFilter.rejected:
        return tasks.where((task) => task.isRejected).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ParentChildDetailsController>();

    final filteredTasks = _filteredTasks(controller.tasks);

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          title: AppPageHeader(
            isArabic: widget.isArabic,
            title: widget.isArabic
                ? 'مهام ${widget.childName}'
                : '${widget.childName}’s Tasks',
          ),
        ),
        body: ScreenBackground(
          child: SafeArea(
            top: false,
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TaskFilterBar(
                      selectedFilter: selectedFilter,
                      isArabic: widget.isArabic,
                      onSelected: (filter) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _TasksSection(
                      controller: controller,
                      childId: widget.childId,
                      isArabic: widget.isArabic,
                      tasks: filteredTasks,
                      selectedFilter: selectedFilter,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskFilterBar extends StatelessWidget {
  final ChildTaskFilter selectedFilter;
  final bool isArabic;
  final ValueChanged<ChildTaskFilter> onSelected;

  const _TaskFilterBar({
    required this.selectedFilter,
    required this.isArabic,
    required this.onSelected,
  });

  String _label(ChildTaskFilter filter) {
    switch (filter) {
      case ChildTaskFilter.all:
        return isArabic ? 'الكل' : 'All';

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
        separatorBuilder: (_, __) {
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

class _TasksSection extends StatelessWidget {
  final ParentChildDetailsController controller;
  final String childId;
  final bool isArabic;
  final List<TaskAssignmentModel> tasks;
  final ChildTaskFilter selectedFilter;

  const _TasksSection({
    required this.controller,
    required this.childId,
    required this.isArabic,
    required this.tasks,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.errorMessage != null && controller.tasks.isEmpty) {
      return _TasksErrorState(
        isArabic: isArabic,
        onRetry: () {
          controller.loadTasks(childId);
        },
      );
    }

    if (controller.tasks.isEmpty) {
      return _TasksEmptyState(isArabic: isArabic);
    }

    if (tasks.isEmpty) {
      return _FilteredTasksEmptyState(
        isArabic: isArabic,
        selectedFilter: selectedFilter,
      );
    }

    return Column(
      children: tasks.map((assignment) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _ChildTaskCard(assignment: assignment, isArabic: isArabic),
        );
      }).toList(),
    );
  }
}

class _ChildTaskCard extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final bool isArabic;

  const _ChildTaskCard({required this.assignment, required this.isArabic});

  String get _statusLabel {
    if (assignment.needsParentApproval) {
      return isArabic ? 'بانتظار المراجعة' : 'Awaiting review';
    }

    if (assignment.isApproved) {
      return isArabic ? 'مكتملة' : 'Completed';
    }

    if (assignment.isRejected) {
      return isArabic ? 'مرفوضة' : 'Rejected';
    }

    if (assignment.isPending) {
      return isArabic ? 'نشطة' : 'Active';
    }

    return isArabic ? 'مكتملة' : 'Completed';
  }

  Color get _statusColor {
    if (assignment.needsParentApproval) {
      return const Color(0xFFB7791F);
    }

    if (assignment.isApproved) {
      return AppColors.success;
    }

    if (assignment.isRejected) {
      return AppColors.error;
    }

    return AppColors.primaryDark;
  }

  Color get _statusBackground {
    if (assignment.needsParentApproval) {
      return const Color(0xFFFFF1D6);
    }

    if (assignment.isApproved) {
      return const Color(0xFFE4F4E8);
    }

    if (assignment.isRejected) {
      return const Color(0xFFF9DEDE);
    }

    return AppColors.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.task_alt_outlined,
              color: AppColors.primaryDark,
              size: 21,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.task.title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 13, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  '${assignment.task.points}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilteredTasksEmptyState extends StatelessWidget {
  final bool isArabic;
  final ChildTaskFilter selectedFilter;

  const _FilteredTasksEmptyState({
    required this.isArabic,
    required this.selectedFilter,
  });

  String get message {
    switch (selectedFilter) {
      case ChildTaskFilter.active:
        return isArabic ? 'لا توجد مهام نشطة' : 'No active tasks';

      case ChildTaskFilter.awaitingReview:
        return isArabic
            ? 'لا توجد مهام بانتظار المراجعة'
            : 'No tasks awaiting review';

      case ChildTaskFilter.completed:
        return isArabic ? 'لا توجد مهام مكتملة' : 'No completed tasks';

      case ChildTaskFilter.rejected:
        return isArabic ? 'لا توجد مهام مرفوضة' : 'No rejected tasks';

      case ChildTaskFilter.all:
        return isArabic ? 'لا توجد مهام' : 'No tasks';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.filter_alt_off_outlined,
            size: 36,
            color: AppColors.primary,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TasksEmptyState extends StatelessWidget {
  final bool isArabic;

  const _TasksEmptyState({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.task_alt_outlined,
            size: 36,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isArabic
                ? 'لا توجد مهام لهذا الطفل بعد'
                : 'This child has no tasks yet',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TasksErrorState extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onRetry;

  const _TasksErrorState({required this.isArabic, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            isArabic
                ? 'تعذّر تحميل مهام الطفل.'
                : 'Could not load the child’s tasks.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onRetry,
            child: Text(isArabic ? 'إعادة المحاولة' : 'Try again'),
          ),
        ],
      ),
    );
  }
}
