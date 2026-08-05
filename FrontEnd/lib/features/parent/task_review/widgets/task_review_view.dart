import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/task_review_controller.dart';
import '../models/review_task.dart';
import 'task_review_states.dart';

class TaskReviewView extends StatelessWidget {
  final bool isArabic;
  final Future<void> Function(ReviewTask item) onApprove;
  final Future<void> Function(ReviewTask item) onRetry;
  final VoidCallback onBack;

  const TaskReviewView({
    super.key,
    required this.isArabic,
    required this.onApprove,
    required this.onRetry,
    required this.onBack,
  });

  String _tr(String arabic, String english) {
    return isArabic ? arabic : english;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskReviewController>();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: ScreenBackground(
          child: SafeArea(
            child: AppRefreshIndicator(
              onRefresh: controller.loadPendingTasks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPageHeader(
                      isArabic: isArabic,
                      title: _tr('مراجعة المهام', 'Task Review'),
                      onBack: onBack,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      _tr(
                        'راجع ما أنجزه أطفالك',
                        'Review your children’s completed tasks',
                      ),
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    if (!controller.isLoading &&
                        controller.errorMessage == null)
                      PendingHeader(
                        count: controller.pendingTasks.length,
                        isArabic: isArabic,
                      ),

                    const SizedBox(height: AppSpacing.md),

                    if (controller.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (controller.errorMessage != null)
                      TaskReviewErrorCard(
                        message: controller.errorMessage!,
                        isArabic: isArabic,
                        onRetry: controller.loadPendingTasks,
                      )
                    else if (controller.pendingTasks.isEmpty)
                      EmptyCard(isArabic: isArabic)
                    else
                      ...controller.pendingTasks.map((item) {
                        final assignmentId = item.assignment.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ReviewTaskCard(
                            item: item,
                            isArabic: isArabic,
                            timeText: controller.formatCompletedTime(
                              item.assignment.completedAt,
                            ),
                            isUpdating: controller.isUpdating(assignmentId),
                            isApproving: controller.isApproving(assignmentId),
                            isRetrying: controller.isRetrying(assignmentId),
                            onApprove: () {
                              onApprove(item);
                            },
                            onRetry: () {
                              onRetry(item);
                            },
                          ),
                        );
                      }),

                    const SizedBox(height: AppSpacing.lg),
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
