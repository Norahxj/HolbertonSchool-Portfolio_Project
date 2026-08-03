import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_refresh_indicator.dart';
import '../../../core/widgets/child_avatar.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/child_model.dart';
import '../../../models/task_assignment_model.dart';
import '../../../services/task_api_service.dart';

class TaskReviewScreen extends StatefulWidget {
  final bool isArabic;

  const TaskReviewScreen({super.key, required this.isArabic});

  @override
  State<TaskReviewScreen> createState() => _TaskReviewScreenState();
}

class _ReviewTask {
  final ChildModel child;
  final TaskAssignmentModel assignment;

  const _ReviewTask({required this.child, required this.assignment});
}

class _TaskReviewScreenState extends State<TaskReviewScreen> {
  final TaskApiService _taskApiService = TaskApiService();

  List<_ReviewTask> pendingTasks = [];

  bool isLoading = true;
  String? errorMessage;

  String? updatingAssignmentId;
  String? updatingAction;

  String tr(String arabic, String english) {
    return widget.isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();
    _loadPendingTasks();
  }

  Future<void> _loadPendingTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final assignments =
    await _taskApiService.getPendingReviewAssignments();

final reviewTasks = assignments
    .where((assignment) => assignment.child != null)
    .map(
      (assignment) => _ReviewTask(
        child: assignment.child!,
        assignment: assignment,
      ),
    )
    .toList();
      

      reviewTasks.sort((first, second) {
        final firstDate = first.assignment.completedAt;

        final secondDate = second.assignment.completedAt;

        if (firstDate == null && secondDate == null) {
          return 0;
        }

        if (firstDate == null) {
          return 1;
        }

        if (secondDate == null) {
          return -1;
        }

        return secondDate.compareTo(firstDate);
      });

      if (!mounted) return;

      setState(() {
        pendingTasks = reviewTasks;
        isLoading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;

      debugPrint(
        'Review loading failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      setState(() {
        errorMessage =
            _readBackendMessage(error) ??
            tr('تعذر تحميل المهام', 'Unable to load tasks');

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('Review loading failed: $error');

      setState(() {
        errorMessage = tr('تعذر تحميل المهام', 'Unable to load tasks');

        isLoading = false;
      });
    }
  }

  Future<void> _approveTask(_ReviewTask item) async {
    if (updatingAssignmentId != null) {
      return;
    }

    setState(() {
      updatingAssignmentId = item.assignment.id;

      updatingAction = 'approve';
    });

    try {
      await _taskApiService.approveAssignment(item.assignment.id);

      if (!mounted) return;

      setState(() {
        pendingTasks.removeWhere(
          (task) => task.assignment.id == item.assignment.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${tr('تم قبول مهمة ', 'Task accepted: ')}'
            '"${item.assignment.task.title}"',
          ),
        ),
      );
    } on DioException catch (error) {
      if (!mounted) return;

      debugPrint(
        'Approval failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      final statusCode = error.response?.statusCode;

      final message = statusCode == 404
          ? tr(
              'لا يمكنك قبول هذه المهمة؛ يمكن قبولها فقط بواسطة ولي الأمر الذي أضافها.',
              'Only the guardian who created this task can accept it.',
            )
          : _readBackendMessage(error) ??
                tr('تعذر قبول المهمة', 'Unable to accept the task');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          updatingAssignmentId = null;
          updatingAction = null;
        });
      }
    }
  }

  Future<void> _sendBackForRetry(_ReviewTask item) async {
    if (updatingAssignmentId != null) {
      return;
    }

    setState(() {
      updatingAssignmentId = item.assignment.id;

      updatingAction = 'retry';
    });

    try {
      // The backend rejection action returns the task to the child
      // so the child can try it again.
      await _taskApiService.rejectAssignment(item.assignment.id);

      if (!mounted) return;

      setState(() {
        pendingTasks.removeWhere(
          (task) => task.assignment.id == item.assignment.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${tr('تم إرسال المهمة لإعادة المحاولة: ', 'Task sent back for another try: ')}'
            '"${item.assignment.task.title}"',
          ),
        ),
      );
    } on DioException catch (error) {
      if (!mounted) return;

      debugPrint(
        'Retry request failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      final statusCode = error.response?.statusCode;

      final message = statusCode == 404
          ? tr(
              'لا يمكنك إرسال هذه المهمة لإعادة المحاولة؛ يمكن ذلك فقط بواسطة ولي الأمر الذي أضافها.',
              'Only the guardian who created this task can send it back for another try.',
            )
          : _readBackendMessage(error) ??
                tr(
                  'تعذر إرسال المهمة لإعادة المحاولة',
                  'Unable to send the task back for another try',
                );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          updatingAssignmentId = null;
          updatingAction = null;
        });
      }
    }
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString();
    }

    return null;
  }

  String _formatCompletedTime(DateTime? completedAt) {
    if (completedAt == null) {
      return tr('أُنجزت مؤخرًا', 'Completed recently');
    }

    final date = completedAt.toLocal();

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return tr('أُنجزت في $hour:$minute', 'Completed at $hour:$minute');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: ScreenBackground(
          child: SafeArea(
            child: AppRefreshIndicator(
              onRefresh: _loadPendingTasks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPageHeader(
                      isArabic: widget.isArabic,
                      title: tr('مراجعة المهام', 'Task Review'),
                      onBack: () {
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      tr(
                        'راجع ما أنجزه أطفالك',
                        'Review your children’s completed tasks',
                      ),
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    if (!isLoading && errorMessage == null)
                      _PendingHeader(
                        count: pendingTasks.length,
                        isArabic: widget.isArabic,
                      ),

                    const SizedBox(height: AppSpacing.md),

                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (errorMessage != null)
                      _ErrorCard(
                        message: errorMessage!,
                        isArabic: widget.isArabic,
                        onRetry: _loadPendingTasks,
                      )
                    else if (pendingTasks.isEmpty)
                      _EmptyCard(isArabic: widget.isArabic)
                    else
                      ...pendingTasks.map((item) {
                        final isUpdating =
                            updatingAssignmentId == item.assignment.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _ReviewTaskCard(
                            item: item,
                            isArabic: widget.isArabic,
                            timeText: _formatCompletedTime(
                              item.assignment.completedAt,
                            ),
                            isUpdating: isUpdating,
                            isApproving:
                                isUpdating && updatingAction == 'approve',
                            isRetrying: isUpdating && updatingAction == 'retry',
                            onApprove: () {
                              _approveTask(item);
                            },
                            onRetry: () {
                              _sendBackForRetry(item);
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

class _PendingHeader extends StatelessWidget {
  final int count;
  final bool isArabic;

  const _PendingHeader({required this.count, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isArabic ? 'بانتظار المراجعة' : 'Pending review',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isArabic ? '$count مهام' : '$count tasks',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewTaskCard extends StatelessWidget {
  final _ReviewTask item;
  final bool isArabic;
  final String timeText;

  final bool isUpdating;
  final bool isApproving;
  final bool isRetrying;

  final VoidCallback onApprove;
  final VoidCallback onRetry;

  const _ReviewTaskCard({
    required this.item,
    required this.isArabic,
    required this.timeText,
    required this.isUpdating,
    required this.isApproving,
    required this.isRetrying,
    required this.onApprove,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ChildAvatar(avatarIndex: item.child.avatarIndex, size: 42),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.child.name,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      item.assignment.task.title,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      timeText,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
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
                      color: AppColors.gold,
                      size: 14,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      '${item.assignment.task.points}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUpdating ? null : onApprove,
                  icon: isApproving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(isArabic ? 'مقبولة' : 'Accepted'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primaryLight,
                    disabledForegroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isUpdating ? null : onRetry,
                  icon: isRetrying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    isArabic ? 'إعادة المحاولة' : 'Try Again',
                    textAlign: TextAlign.center,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final bool isArabic;

  const _EmptyCard({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_outlined,
            color: AppColors.primary,
            size: 42,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            isArabic
                ? 'لا توجد مهام بانتظار المراجعة'
                : 'No tasks are pending review',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final bool isArabic;
  final Future<void> Function() onRetry;

  const _ErrorCard({
    required this.message,
    required this.isArabic,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            message,
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
