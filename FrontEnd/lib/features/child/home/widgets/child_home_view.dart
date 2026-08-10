import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/screen_background.dart';
import '../../../../models/task_assignment_model.dart';
import '../controllers/child_home_controller.dart';
import '../models/child_home_action_result.dart';
import 'child_assignment_card.dart';
import 'child_home_error_state.dart';
import 'child_home_header.dart';
import 'child_home_section_header.dart';
import 'daily_feedback_card.dart';
import 'daily_goal_card.dart';
import 'empty_tasks_card.dart';
import 'encouragement_card.dart';

class ChildHomeView extends StatelessWidget {
  final VoidCallback onSettingsPressed;

  final Future<void> Function() onRefresh;

  final Future<void> Function() onRetry;

  final Future<void> Function(String assignmentId) onCompleteAssignment;

  final Future<void> Function(
    TaskAssignmentModel assignment,
    IconData icon,
  ) onAssignmentTap;

  const ChildHomeView({
    super.key,
    required this.onSettingsPressed,
    required this.onRefresh,
    required this.onRetry,
    required this.onCompleteAssignment,
    required this.onAssignmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChildHomeController>();

    if (controller.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final child = controller.child;

    if (controller.hasError || child == null) {
      final message =
          controller.backendMessage ??
          (controller.errorCode == ChildHomeErrorCode.childNotFound
              ? context.l10n.childHomeChildNotFound
              : context.l10n.childHomeLoadFailed);

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: ChildHomeErrorState(
            message: message,
            onRetry: onRetry,
          ),
        ),
      );
    }

    final assignments = controller.assignments;
    final completedCount = controller.completedCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: Column(
          children: [
            RepaintBoundary(
              child: ChildHomeHeader(
                childName: child.name,
                avatarIndex: child.avatarIndex,
                points: controller.points,
                completedTasks: completedCount,
                totalTasks: assignments.length,
                onSettingsPressed: onSettingsPressed,
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DailyGoalCard(
                        completedTasks: completedCount,
                        totalTasks: assignments.length,
                      ),

                      if (controller.todayFeedback != null) ...[
                        const SizedBox(height: AppSpacing.md),

                        DailyFeedbackCard(
                          feedback: controller.todayFeedback!,
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xl),

                      ChildHomeSectionHeader(
                        title: context.l10n.todayTasks,
                        count: '${assignments.length}',
                      ),

                      const SizedBox(height: AppSpacing.md),

                      if (assignments.isEmpty)
                        const EmptyTasksCard()
                      else
                        ...assignments.map(
                          (assignment) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: ChildAssignmentCard(
                              assignment: assignment,
                              isUpdating:
                                  controller.isUpdatingAssignment(
                                    assignment.id,
                                  ),
                              onComplete:
                                  controller.canCompleteAssignment(
                                    assignment,
                                  )
                                  ? () => onCompleteAssignment(
                                      assignment.id,
                                    )
                                  : null,
                              onTap: () {
                                final category =
                                    childHomeCategoryStyle(
                                      assignment.task.category,
                                    );

                                onAssignmentTap(
                                  assignment,
                                  category.icon,
                                );
                              },
                            ),
                          ),
                        ),

                      if (assignments.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),

                        const EncouragementCard(),
                      ],

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}