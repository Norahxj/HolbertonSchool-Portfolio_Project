import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/child_dashboard_model.dart';
import '../../../models/child_model.dart';
import '../../../models/task_assignment_model.dart';
import '../../../services/task_api_service.dart';

class ChildProfileScreen extends StatefulWidget {
  final ChildModel child;
  final ChildDashboardModel dashboard;

  const ChildProfileScreen({
    super.key,
    required this.child,
    required this.dashboard,
  });

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final TaskApiService _taskApiService = TaskApiService();

  List<TaskAssignmentModel> assignments = [];

  bool isLoading = true;
  String? errorMessage;
  String? approvingAssignmentId;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _taskApiService.getAssignmentsForChild(
        widget.child.id,
      );

      if (!mounted) return;

      setState(() {
        assignments = result;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('Child assignments error: $error');

      setState(() {
        errorMessage = 'تعذر تحميل المهام';
        isLoading = false;
      });
    }
  }

  Future<void> _approveAssignment(TaskAssignmentModel assignment) async {
    if (!assignment.needsParentApproval || approvingAssignmentId != null) {
      return;
    }

    setState(() {
      approvingAssignmentId = assignment.id;
    });

    try {
      await _taskApiService.approveAssignment(assignment.id);

      await _loadAssignments();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم اعتماد المهمة')));
    } on DioException catch (error) {
      if (!mounted) return;

      final data = error.response?.data;

      String? message;

      if (data is Map) {
        message = data['error']?.toString();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message ?? 'تعذر اعتماد المهمة')));
    } finally {
      if (mounted) {
        setState(() {
          approvingAssignmentId = null;
        });
      }
    }
  }

  int get completedTasks {
    return assignments.where((assignment) {
      return assignment.countsTowardProgress;
    }).length;
  }

  int get totalTasks {
    return assignments.length;
  }

  double get progress {
    if (totalTasks == 0) {
      return 0;
    }

    return completedTasks / totalTasks * 100;
  }

  IconData _getTaskIcon(String? category) {
    switch (category?.toUpperCase()) {
      case 'RELIGIOUS':
        return Icons.mosque_outlined;

      case 'FINANCIAL':
        return Icons.credit_card_outlined;

      case 'MORAL':
        return Icons.favorite_border;

      case 'SOCIAL':
        return Icons.groups_outlined;

      default:
        return Icons.task_alt_outlined;
    }
  }

  String? _getStatusText(TaskAssignmentModel assignment) {
    if (assignment.isApproved) {
      return 'مكتملة';
    }

    if (assignment.needsParentApproval) {
      return 'بانتظار اعتماد ولي الأمر';
    }

    if (assignment.isRejected) {
      return 'مرفوضة';
    }

    // No text is displayed for unfinished tasks.
    return null;
  }

  Color _getStatusColor(TaskAssignmentModel assignment) {
    if (assignment.isApproved) {
      return AppColors.success;
    }

    if (assignment.needsParentApproval) {
      return const Color(0xFFC08A3E);
    }

    if (assignment.isRejected) {
      return AppColors.error;
    }

    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final useDashboardFallback = isLoading || errorMessage != null;

    final displayedProgress = useDashboardFallback
        ? widget.dashboard.progressPercentage
        : progress;

    final displayedCompleted = useDashboardFallback
        ? widget.dashboard.approvedTasks
        : completedTasks;

    final displayedTotal = useDashboardFallback
        ? widget.dashboard.totalTasks
        : totalTasks;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _ProfileHeader(child: widget.child),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAssignments,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _WeeklyProgressCard(
                      progress: displayedProgress,
                      completedTasks: displayedCompleted,
                      totalTasks: displayedTotal,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    _JoinCodeCard(child: widget.child),

                    const SizedBox(height: AppSpacing.lg),

                    _TasksHeader(
                      completedTasks: completedTasks,
                      totalTasks: totalTasks,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (errorMessage != null)
                      _MessageCard(
                        message: errorMessage!,
                        onRetry: _loadAssignments,
                      )
                    else if (assignments.isEmpty)
                      const _MessageCard(message: 'لا توجد مهام لهذا الطفل')
                    else
                      Column(
                        children: assignments.map((assignment) {
                          return _TaskItem(
                            assignment: assignment,
                            icon: _getTaskIcon(assignment.task.category),
                            statusText: _getStatusText(assignment),
                            statusColor: _getStatusColor(assignment),
                            isApproving: approvingAssignmentId == assignment.id,
                            onApprove: () {
                              _approveAssignment(assignment);
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ChildModel child;

  const _ProfileHeader({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  const SizedBox(width: 44),

                  Expanded(
                    child: Center(
                      child: Text(
                        child.name,
                        style: AppTextStyles.arabicTitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  _HeaderBackButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              _LargeChildAvatar(avatarIndex: child.avatarIndex),

              const SizedBox(height: AppSpacing.sm),

              Text(
                '${child.age} سنوات',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _HeaderBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _LargeChildAvatar extends StatelessWidget {
  final int avatarIndex;

  const _LargeChildAvatar({required this.avatarIndex});

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
      width: 130,
      height: 130,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 64),
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  final double progress;
  final int completedTasks;
  final int totalTasks;

  const _WeeklyProgressCard({
    required this.progress,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0, 100).toDouble();

    final percent = safeProgress.round();

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeeklyRing(percent: percent),

              const Text(
                'التقدم الأسبوعي',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: safeProgress / 100,
              minHeight: 8,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$completedTasks من $totalTasks مهام مكتملة',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRing extends StatelessWidget {
  final int percent;

  const _WeeklyRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 5,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),

          Text(
            '$percent%',
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

class _JoinCodeCard extends StatelessWidget {
  final ChildModel child;

  const _JoinCodeCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              _CopyButton(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: child.accessCode));

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('تم نسخ الرمز')));
                },
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      'رمز انضمام ${child.name}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    Text(
                      child.accessCode,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.vpn_key_outlined, color: Colors.white),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        const Text(
          'شارك هذا الرمز مع طفلك لينشئ حسابه',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _CopyButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CopyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.copy_rounded, size: 16),
      label: const Text('نسخ'),
    );
  }
}

class _TasksHeader extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;

  const _TasksHeader({required this.completedTasks, required this.totalTasks});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (totalTasks > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$completedTasks/$totalTasks مكتملة',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ),

        Text(
          'مهام اليوم',
          textDirection: TextDirection.rtl,
          style: AppTextStyles.arabicTitle.copyWith(fontSize: 18),
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final IconData icon;
  final String? statusText;
  final Color statusColor;
  final bool isApproving;
  final VoidCallback onApprove;

  const _TaskItem({
    required this.assignment,
    required this.icon,
    required this.statusText,
    required this.statusColor,
    required this.isApproving,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        // Keeps the status circle on the left
        // and the category icon on the right.
        textDirection: TextDirection.ltr,
        children: [
          _TaskCircle(
            assignment: assignment,
            isApproving: isApproving,
            onApprove: onApprove,
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                // Makes all text use the full available width.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    assignment.task.title,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        '${assignment.task.points} نقاط',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),

                      const SizedBox(width: 4),

                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.gold,
                        size: 14,
                      ),
                    ],
                  ),

                  if (statusText != null) ...[
                    const SizedBox(height: 3),

                    Text(
                      statusText!,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
        ],
      ),
    );
  }
}

class _TaskCircle extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final bool isApproving;
  final VoidCallback onApprove;

  const _TaskCircle({
    required this.assignment,
    required this.isApproving,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    if (assignment.isApproved) {
      return const _Circle(color: AppColors.success, icon: Icons.check);
    }

    if (assignment.isRejected) {
      return const _Circle(color: AppColors.error, icon: Icons.close);
    }

    if (assignment.needsParentApproval) {
      return GestureDetector(
        onTap: isApproving ? null : onApprove,
        child: _Circle(
          color: AppColors.primaryLight,
          borderColor: AppColors.primary,
          child: isApproving
              ? const Padding(
                  padding: EdgeInsets.all(7),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check, color: AppColors.primary, size: 18),
        ),
      );
    }

    return const _Circle(
      color: Colors.transparent,
      borderColor: AppColors.border,
    );
  }
}

class _Circle extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final IconData? icon;
  final Widget? child;

  const _Circle({required this.color, this.borderColor, this.icon, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 2),
      ),
      child:
          child ??
          (icon == null ? null : Icon(icon, color: Colors.white, size: 18)),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;

  const _MessageCard({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),

          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
