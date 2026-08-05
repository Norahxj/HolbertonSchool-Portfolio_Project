import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/screen_background.dart';
import '../../../../models/task_assignment_model.dart';
import '../../controllers/parent_child_details_controller.dart';
import '../../models/parent_child_tasks_data.dart';
import 'task_filter_bar.dart';
import 'tasks_section.dart';

class ChildTasksView extends StatefulWidget {
  final String childId;
  final String childName;
  final bool isArabic;
  final ParentChildDetailsController controller;

  final Future<void> Function({
    required String taskId,
    required String taskTitle,
  })
  onDeleteTask;

  const ChildTasksView({
    super.key,
    required this.childId,
    required this.childName,
    required this.isArabic,
    required this.controller,
    required this.onDeleteTask,
  });

  @override
  State<ChildTasksView> createState() => _ChildTasksViewState();
}

class _ChildTasksViewState extends State<ChildTasksView> {
  ChildTaskFilter selectedFilter = ChildTaskFilter.all;

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
    final filteredTasks = _filteredTasks(widget.controller.tasks);

    final filteredUpcomingTasks = _filteredUpcomingTasks(
      widget.controller.upcomingTasks,
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
              onRefresh: widget.controller.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TaskFilterBar(
                      selectedFilter: selectedFilter,
                      isArabic: widget.isArabic,
                      onSelected: (filter) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    TasksSection(
                      controller: widget.controller,
                      childId: widget.childId,
                      isArabic: widget.isArabic,
                      tasks: filteredTasks,
                      upcomingTasks: filteredUpcomingTasks,
                      selectedFilter: selectedFilter,
                      onDeleteTask: widget.onDeleteTask,
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
