import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/screen_background.dart';
import '../../../../models/task_assignment_model.dart';
import '../controllers/child_tasks_controller.dart';
import '../models/upcoming_child_task.dart';
import 'task_filter_bar.dart';
import 'tasks_section.dart';

class ChildTasksView extends StatefulWidget {
  final String childName;
  final VoidCallback onBack;
  final ValueChanged<TaskAssignmentModel> onAssignmentTap;
  final ValueChanged<UpcomingChildTask> onUpcomingTaskTap;

  final Future<void> Function({
    required String taskId,
    required String taskTitle,
  })
  onDeleteTask;

  const ChildTasksView({
    super.key,
    required this.childName,
    required this.onBack,
    required this.onAssignmentTap,
    required this.onUpcomingTaskTap,
    required this.onDeleteTask,
  });

  @override
  State<ChildTasksView> createState() {
    return _ChildTasksViewState();
  }
}

class _ChildTasksViewState extends State<ChildTasksView> {
  ChildTaskFilter _selectedFilter = ChildTaskFilter.all;

  List<TaskAssignmentModel> _filteredTasks(List<TaskAssignmentModel> tasks) {
    switch (_selectedFilter) {
      case ChildTaskFilter.all:
        return tasks;

      case ChildTaskFilter.upcoming:
        return const [];

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

  List<UpcomingChildTask> _filteredUpcomingTasks(
    List<UpcomingChildTask> upcomingTasks,
  ) {
    if (_selectedFilter == ChildTaskFilter.all ||
        _selectedFilter == ChildTaskFilter.upcoming) {
      return upcomingTasks;
    }

    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChildTasksController>();

    final tasks = _filteredTasks(controller.tasks);

    final upcomingTasks = _filteredUpcomingTasks(controller.upcomingTasks);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: AppPageHeader(
          title: context.l10n.childTasksTitle(widget.childName),
          onBack: widget.onBack,
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
                  TaskFilterBar(
                    selectedFilter: _selectedFilter,
                    onSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TasksSection(
                    controller: controller,
                    tasks: tasks,
                    upcomingTasks: upcomingTasks,
                    selectedFilter: _selectedFilter,
                    onAssignmentTap: widget.onAssignmentTap,
                    onUpcomingTaskTap: widget.onUpcomingTaskTap,
                    onDeleteTask: widget.onDeleteTask,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
