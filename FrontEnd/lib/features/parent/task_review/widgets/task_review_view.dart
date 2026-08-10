import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/task_review_controller.dart';
import '../models/review_task.dart';
import '../utils/task_review_localization.dart';
import 'task_review_states.dart';

class TaskReviewView extends StatelessWidget {
  final Future<void> Function(ReviewTask item) onApprove;
  final Future<void> Function(ReviewTask item) onRetry;
  final VoidCallback onBack;

  const TaskReviewView({
    super.key,
    required this.onApprove,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        context.watch<TaskReviewController>();

    final errorMessage =
        controller.backendMessage ??
        controller.errorCode?.localized(context);

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: AppRefreshIndicator(
            onRefresh: controller.loadPendingTasks,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    title: context.l10n.taskReview,
                    onBack: onBack,
                  ),

                  const SizedBox(
                    height: AppSpacing.sm,
                  ),

                  Text(
                    context.l10n.reviewCompletedTasks,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  if (!controller.isLoading &&
                      errorMessage == null)
                    PendingHeader(
                      count:
                          controller.pendingTasks.length,
                    ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  if (controller.isLoading)
                    const Padding(
                      padding:
                          EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    )
                  else if (errorMessage != null)
                    TaskReviewErrorCard(
                      message: errorMessage,
                      onRetry:
                          controller.loadPendingTasks,
                    )
                  else if (controller
                      .pendingTasks.isEmpty)
                    const EmptyCard()
                  else
                    ...controller.pendingTasks.map(
                      (item) {
                        final assignmentId =
                            item.assignment.id;

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: AppSpacing.md,
                          ),
                          child: ReviewTaskCard(
                            item: item,
                            timeText:
                                formatTaskCompletedTime(
                              context,
                              item.assignment.completedAt,
                            ),
                            isUpdating:
                                controller.isUpdating(
                              assignmentId,
                            ),
                            isApproving:
                                controller.isApproving(
                              assignmentId,
                            ),
                            isRetrying:
                                controller.isRetrying(
                              assignmentId,
                            ),
                            onApprove: () {
                              onApprove(item);
                            },
                            onRetry: () {
                              onRetry(item);
                            },
                          ),
                        );
                      },
                    ),

                  const SizedBox(
                    height: AppSpacing.lg,
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