import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../child/screens/child_task_details_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/task_assignment_model.dart';
import '../controllers/parent_child_details_controller.dart';
import '../models/parent_child_tasks_data.dart';

enum ChildTaskFilter {
  all,
  upcoming,
  active,
  awaitingReview,
  completed,
  rejected,
}

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
  Future<void> _confirmDeleteTask({
  required String taskId,
  required String taskTitle,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          widget.isArabic ? 'حذف المهمة؟' : 'Delete task?',
        ),
        content: Text(
  widget.isArabic
      ? 'سيتم حذف مهمة "$taskTitle" نهائيًا، ولا يمكن التراجع عن هذا الإجراء.'
      : 'The task "$taskTitle" will be permanently deleted. This action cannot be undone.',
),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(
              widget.isArabic ? 'إلغاء' : 'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(
              widget.isArabic ? 'حذف' : 'Delete',
            ),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true || !mounted) {
    return;
  }

  final controller = context.read<ParentChildDetailsController>();

  final errorMessage = await controller.deleteTask(taskId);

  if (!mounted) {
    return;
  }

  if (errorMessage != null) {
  final message = errorMessage == 'You can only delete tasks you created.'
      ? widget.isArabic
          ? 'لا يمكنك حذف هذه المهمة لأنها أُنشئت بواسطة ولي أمر آخر.'
          : 'You cannot delete this task because it was created by another parent.'
      : widget.isArabic
          ? 'تعذر حذف المهمة. حاولي مرة أخرى.'
          : errorMessage;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );

  return;
}

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        widget.isArabic
            ? 'تم حذف المهمة بنجاح'
            : 'Task deleted successfully',
      ),
    ),
  );
}

  List<TaskAssignmentModel> _filteredTasks(List<TaskAssignmentModel> tasks) {
    switch (selectedFilter) {
      case ChildTaskFilter.all:
        return tasks;

      case ChildTaskFilter.upcoming:
        return [];

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

  List<UpcomingTaskItem> _filteredUpcomingTasks(
    List<UpcomingTaskItem> upcomingTasks,
  ) {
    if (selectedFilter == ChildTaskFilter.all ||
        selectedFilter == ChildTaskFilter.upcoming) {
      return upcomingTasks;
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ParentChildDetailsController>();

    final filteredTasks = _filteredTasks(controller.tasks);

    final filteredUpcomingTasks = _filteredUpcomingTasks(
      controller.upcomingTasks,
    );

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
  upcomingTasks: filteredUpcomingTasks,
  selectedFilter: selectedFilter,
  onDeleteTask: ({
    required String taskId,
    required String taskTitle,
  }) {
    return _confirmDeleteTask(
      taskId: taskId,
      taskTitle: taskTitle,
    );
  },
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

class _TasksSection extends StatelessWidget {
  final ParentChildDetailsController controller;
  final String childId;
  final bool isArabic;
  final List<TaskAssignmentModel> tasks;
  final List<UpcomingTaskItem> upcomingTasks;
  final ChildTaskFilter selectedFilter;

  final Future<void> Function({
  required String taskId,
  required String taskTitle,
}) onDeleteTask;

  const _TasksSection({
  required this.controller,
  required this.childId,
  required this.isArabic,
  required this.tasks,
  required this.upcomingTasks,
  required this.selectedFilter,
  required this.onDeleteTask,
});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.hasNoTaskData) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.errorMessage != null && controller.hasNoTaskData) {
      return _TasksErrorState(
        isArabic: isArabic,
        onRetry: () {
          controller.loadTasks(childId);
        },
      );
    }

    if (controller.hasNoTaskData) {
      return _TasksEmptyState(isArabic: isArabic);
    }

    if (tasks.isEmpty && upcomingTasks.isEmpty) {
      return _FilteredTasksEmptyState(
        isArabic: isArabic,
        selectedFilter: selectedFilter,
      );
    }

    return Column(
      children: [
        for (final upcomingTask in upcomingTasks)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _UpcomingTaskCard(
  item: upcomingTask,
  isArabic: isArabic,
  canDelete: controller.canDeleteTask(
    upcomingTask.task.id,
  ),
  onDelete: () {
    return onDeleteTask(
      taskId: upcomingTask.task.id,
      taskTitle: upcomingTask.task.title,
    );
  },
),
          ),

        for (final assignment in tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ChildTaskCard(
  assignment: assignment,
  isArabic: isArabic,
  canDelete: controller.canDeleteTask(
    assignment.task.id,
  ),
  onDelete: () {
    return onDeleteTask(
      taskId: assignment.task.id,
      taskTitle: assignment.task.title,
    );
  },
),
          ),
      ],
    );
  }
}

class _UpcomingTaskCard extends StatelessWidget {
  final UpcomingTaskItem item;
  final bool isArabic;
  final bool canDelete;
final Future<void> Function() onDelete;

const _UpcomingTaskCard({
  required this.item,
  required this.isArabic,
  required this.canDelete,
  required this.onDelete,
});
  String get _frequencyLabel {
    final frequency = item.task.taskFrequency.toUpperCase();

    if (frequency == 'WEEKLY') {
      return isArabic ? 'أسبوعية' : 'Weekly';
    }

    return isArabic ? 'شهرية' : 'Monthly';
  }

  String get _formattedDate {
    final date = item.nextDate;

    final arabicWeekdays = [
      '',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    final englishWeekdays = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final arabicMonths = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final englishMonths = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final weekday = isArabic
        ? arabicWeekdays[date.weekday]
        : englishWeekdays[date.weekday];

    final month = isArabic
        ? arabicMonths[date.month]
        : englishMonths[date.month];

    final separator = isArabic ? '،' : ',';

    return '$weekday$separator ${date.day} $month ${date.year}';
  }

  TaskAssignmentModel get _displayAssignment {
    return TaskAssignmentModel(
      id: '',
      status: 'PENDING',
      assignedDate: item.nextDate,
      task: AssignmentTask(
        id: item.task.id,
        title: item.task.title,
        description: item.task.description,
        points: item.task.points,
        taskFrequency: item.task.taskFrequency,
        recurrenceDay: item.task.recurrenceDay,
        category: item.task.category,
        isAutoVerified: item.task.isAutoVerified,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChildTaskDetailsScreen(
                assignment: _displayAssignment,
                icon: Icons.event_available_outlined,
                isArabic: isArabic,
                parentView: true,
              ),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.32),
            ),
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
                  Icons.event_available_outlined,
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
                      item.task.title,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isArabic ? 'قادمة' : 'Upcoming',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),

                        Text(
                          _frequencyLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      isArabic
                          ? 'الموعد القادم: $_formattedDate'
                          : 'Next date: $_formattedDate',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),
              if (canDelete) ...[
  IconButton(
    onPressed: onDelete,
    tooltip: isArabic ? 'حذف المهمة' : 'Delete task',
    icon: const Icon(
      Icons.delete_outline_rounded,
      color: AppColors.error,
      size: 21,
    ),
  ),

  const SizedBox(width: 2),
],

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 13,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.task.points}',
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
        ),
      ),
    );
  }
}

class _ChildTaskCard extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final bool isArabic;
  final bool canDelete;
  final Future<void> Function() onDelete;

  const _ChildTaskCard({
    required this.assignment,
    required this.isArabic,
    required this.canDelete,
    required this.onDelete,
  });

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChildTaskDetailsScreen(
                assignment: assignment,
                icon: Icons.task_alt_outlined,
                isArabic: isArabic,
                parentView: true,
              ),
            ),
          );
        },
        child: Ink(
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

              if (canDelete)
                IconButton(
                  onPressed: () async {
                    await onDelete();
                  },
                  tooltip: isArabic ? 'حذف المهمة' : 'Delete task',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 21,
                  ),
                ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 13,
                      color: AppColors.gold,
                    ),
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
        ),
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
      case ChildTaskFilter.upcoming:
        return isArabic ? 'لا توجد مهام قادمة' : 'No upcoming tasks';

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
