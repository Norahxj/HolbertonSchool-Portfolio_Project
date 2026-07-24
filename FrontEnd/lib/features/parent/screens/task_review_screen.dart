import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/child_model.dart';
import '../../../models/task_assignment_model.dart';
import '../../../services/task_api_service.dart';
import '../services/child_api_service.dart';

class TaskReviewScreen extends StatefulWidget {
  const TaskReviewScreen({super.key});

  @override
  State<TaskReviewScreen> createState() => _TaskReviewScreenState();
}

class _ReviewTask {
  final ChildModel child;
  final TaskAssignmentModel assignment;

  const _ReviewTask({required this.child, required this.assignment});
}

class _TaskReviewScreenState extends State<TaskReviewScreen> {
  final ChildApiService _childApiService = ChildApiService();

  final TaskApiService _taskApiService = TaskApiService();

  List<_ReviewTask> pendingTasks = [];

  bool isLoading = true;
  String? errorMessage;
  String? updatingAssignmentId;

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
      final children = await _childApiService.getChildren();

      final reviewTasks = <_ReviewTask>[];

      final assignmentsByChild = await Future.wait(
  children.map((child) async {
    final assignments =
        await _taskApiService.getAssignmentsForChild(child.id);

    return MapEntry(child, assignments);
  }),
);

for (final entry in assignmentsByChild) {
  final child = entry.key;
  final assignments = entry.value;

  for (final assignment in assignments) {
    if (assignment.needsParentApproval) {
      reviewTasks.add(
        _ReviewTask(
          child: child,
          assignment: assignment,
        ),
      );
    }
  }
}

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
        errorMessage = _readBackendMessage(error) ?? 'تعذر تحميل المهام';
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('Review loading failed: $error');

      setState(() {
        errorMessage = 'تعذر تحميل المهام';
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
            'تم اعتماد مهمة '
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_readBackendMessage(error) ?? 'تعذر اعتماد المهمة'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          updatingAssignmentId = null;
        });
      }
    }
  }

  Future<void> _rejectTask(_ReviewTask item) async {
    if (updatingAssignmentId != null) {
      return;
    }

    setState(() {
      updatingAssignmentId = item.assignment.id;
    });

    try {
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
            'تم رفض مهمة '
            '"${item.assignment.task.title}"',
          ),
        ),
      );
    } on DioException catch (error) {
      if (!mounted) return;

      debugPrint(
        'Rejection failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_readBackendMessage(error) ?? 'تعذر رفض المهمة'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          updatingAssignmentId = null;
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
      return 'أُنجزت مؤخرًا';
    }

    final date = completedAt.toLocal();

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return 'أُنجزت في $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadPendingTasks,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      const SizedBox(width: 44),

                      Expanded(
                        child: Center(
                          child: Text(
                            'مراجعة المهام',
                            style: AppTextStyles.arabicTitle,
                          ),
                        ),
                      ),

                      _BackButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'راجع ما أنجزه أطفالك واعتمده',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (!isLoading && errorMessage == null)
                    _PendingHeader(count: pendingTasks.length),

                  const SizedBox(height: AppSpacing.md),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (errorMessage != null)
                    _ErrorCard(
                      message: errorMessage!,
                      onRetry: _loadPendingTasks,
                    )
                  else if (pendingTasks.isEmpty)
                    const _EmptyCard()
                  else
                    ...pendingTasks.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _ReviewTaskCard(
                          item: item,
                          timeText: _formatCompletedTime(
                            item.assignment.completedAt,
                          ),
                          isUpdating:
                              updatingAssignmentId == item.assignment.id,
                          onApprove: () {
                            _approveTask(item);
                          },
                          onReject: () {
                            _rejectTask(item);
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
    );
  }
}

class _PendingHeader extends StatelessWidget {
  final int count;

  const _PendingHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFDDA15E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count مهام',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),

        const Text(
          'بانتظار المراجعة',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ReviewTaskCard extends StatelessWidget {
  final _ReviewTask item;
  final String timeText;
  final bool isUpdating;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ReviewTaskCard({
    required this.item,
    required this.timeText,
    required this.isUpdating,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.ltr,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${item.assignment.task.points} ✦',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.child.name} · '
                        '${item.assignment.task.title}',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        timeText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _ChildAvatar(avatarIndex: item.child.avatarIndex),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUpdating ? null : onApprove,
                  icon: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: const Text('اعتماد'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isUpdating ? null : onReject,
                  icon: const Icon(Icons.close),
                  label: const Text('رفض'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.error,
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

class _ChildAvatar extends StatelessWidget {
  final int avatarIndex;

  const _ChildAvatar({required this.avatarIndex});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color backgroundColor;
    Color iconColor;

    if (avatarIndex == 0) {
      icon = Icons.boy;
      backgroundColor = const Color(0xFFD9F0DD);
      iconColor = const Color(0xFF3E8E5A);
    } else if (avatarIndex == 1) {
      icon = Icons.boy;
      backgroundColor = const Color(0xFFD7E9F7);
      iconColor = const Color(0xFF2B6CA3);
    } else if (avatarIndex == 2) {
      icon = Icons.girl;
      backgroundColor = AppColors.primaryLight;
      iconColor = AppColors.primary;
    } else {
      icon = Icons.girl;
      backgroundColor = const Color(0xFFFBE3EA);
      iconColor = const Color(0xFFD1637F);
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 21),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(Icons.verified_outlined, color: AppColors.success, size: 42),

          SizedBox(height: AppSpacing.sm),

          Text(
            'لا توجد مهام بانتظار المراجعة',
            textAlign: TextAlign.center,
            style: TextStyle(
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
  final Future<void> Function() onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),

          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}
