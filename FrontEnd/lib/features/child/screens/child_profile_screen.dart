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
  final ChildDashboardModel? dashboard;

  const ChildProfileScreen({
    super.key,
    required this.child,
    this.dashboard,
  });

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final TaskApiService _taskApiService = TaskApiService();

  bool isLoading = true;
  bool isApproving = false;
  String? errorMessage;

  List<TaskAssignmentModel> assignments = [];

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
      final result = await _taskApiService.getAssignmentsForChild(widget.child.id);

      if (!mounted) return;

      setState(() {
        assignments = result;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'تعذر تحميل المهام';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _approveAssignment(String assignmentId) async {
    if (isApproving) return;

    setState(() {
      isApproving = true;
    });

    try {
      await _taskApiService.approveAssignment(assignmentId);
      await _loadAssignments();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر اعتماد المهمة'),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isApproving = false;
      });
    }
  }

  int get completedTasksCount {
    return assignments.where((assignment) {
      final status = assignment.status.toLowerCase();
      return status == 'completed' || status == 'approved';
    }).length;
  }

  int get totalTasksCount => assignments.length;

  int get progressPercent {
    if (totalTasksCount == 0) return 0;
    return ((completedTasksCount / totalTasksCount) * 100).round();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _ProfileHeader(child: widget.child),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _WeeklyProgressCard(
                    progress: progressPercent.toDouble(),
                    completedTasks: completedTasksCount,
                    totalTasks: totalTasksCount,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _JoinCodeCard(child: widget.child),
                  const SizedBox(height: AppSpacing.lg),
                  _TasksHeader(
                    completedTasks: completedTasksCount,
                    totalTasks: totalTasksCount,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else if (assignments.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'لا توجد مهام لهذا الطفل',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: assignments.map((assignment) {
                        return _TaskItem(
                          label: assignment.task.title,
                          icon: _getTaskIcon(assignment.task.category),
                          status: assignment.status,
                          isAutoVerified: assignment.task.isAutoVerified,
                          isApproving: isApproving,
                          onApprove: () => _approveAssignment(assignment.id),
                        );
                      }).toList(),
                    ),
                ],
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

  const _ProfileHeader({
    required this.child,
  });

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
                  _HeaderIconButton(
                    icon: Icons.arrow_forward_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFBE3EA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.girl,
                      color: Color(0xFFD1637F),
                      size: 64,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: -4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7FDDB0),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${child.age} سنوات',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'التقدم الأسبوعي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              _WeeklyRing(percent: percent),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: safeProgress / 100,
              minHeight: 8,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$completedTasks من $totalTasks مهام مكتملة',
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

  const _WeeklyRing({
    required this.percent,
  });

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
              valueColor: const AlwaysStoppedAnimation(
                AppColors.primary,
              ),
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              fontSize: 13,
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

  const _JoinCodeCard({
    required this.child,
  });

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
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              _CopyButton(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: child.accessCode),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ الرمز'),
                    ),
                  );
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
                    const SizedBox(height: 2),
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
                child: const Icon(
                  Icons.vpn_key_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'شارك هذا الرمز مع طفلك لينشئ حسابه',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CopyButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CopyButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'نسخ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.copy_rounded,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TasksHeader extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;

  const _TasksHeader({
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (totalTasks > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
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
          style: AppTextStyles.arabicTitle.copyWith(fontSize: 18),
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String status;
  final bool isAutoVerified;
  final bool isApproving;
  final VoidCallback onApprove;

  const _TaskItem({
    required this.label,
    required this.icon,
    required this.status,
    required this.isAutoVerified,
    required this.isApproving,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();

    final isApproved = normalizedStatus == 'approved';
    final isCompleted = normalizedStatus == 'completed';
    final isRejected = normalizedStatus == 'rejected';

    final canApprove = isCompleted && !isAutoVerified;

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
        children: [
          _TaskStatusCircle(
            isApproved: isApproved,
            isCompleted: isCompleted,
            isRejected: isRejected,
            canApprove: canApprove,
            isApproving: isApproving,
            onTap: onApprove,
          ),
          Expanded(
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryDark,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskStatusCircle extends StatelessWidget {
  final bool isApproved;
  final bool isCompleted;
  final bool isRejected;
  final bool canApprove;
  final bool isApproving;
  final VoidCallback onTap;

  const _TaskStatusCircle({
    required this.isApproved,
    required this.isCompleted,
    required this.isRejected,
    required this.canApprove,
    required this.isApproving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isApproved) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 18,
        ),
      );
    }

    if (isRejected) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 18,
        ),
      );
    }

    if (canApprove) {
      return GestureDetector(
        onTap: isApproving ? null : onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          child: isApproving
              ? const Padding(
                  padding: EdgeInsets.all(7),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(
                  Icons.check,
                  color: AppColors.primary,
                  size: 18,
                ),
        ),
      );
    }

    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.check,
          color: AppColors.primary,
          size: 18,
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: 2,
        ),
      ),
    );
  }
}