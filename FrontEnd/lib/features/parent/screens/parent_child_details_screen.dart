import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/child_avatar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/task_assignment_model.dart';
import '../controllers/parent_child_details_controller.dart';
import '../controllers/parent_dashboard_controller.dart';
import '../models/parent_dashboard_data.dart';
import '../repositories/parent_child_details_repository.dart';
import 'package:flutter/services.dart';
import 'daily_feedback_screen.dart';
import '../../../core/widgets/app_page_header.dart';
import 'points_history_screen.dart';
import 'child_tasks_screen.dart';
import 'edit_child_screen.dart';

class ParentChildDetailsScreen extends StatelessWidget {
  final ParentDashboardChildItem item;
  final bool isArabic;

  const ParentChildDetailsScreen({
    super.key,
    required this.item,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ParentChildDetailsController(ParentChildDetailsRepository())
            ..loadTasks(item.child.id),
      child: _ParentChildDetailsView(item: item, isArabic: isArabic),
    );
  }
}

class _ParentChildDetailsView extends StatelessWidget {
  final ParentDashboardChildItem item;
  final bool isArabic;

  const _ParentChildDetailsView({required this.item, required this.isArabic});

  Future<void> _confirmDelete(BuildContext context) async {
    final childName = item.child.name;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            title: Text(
              isArabic ? 'حذف $childName؟' : 'Delete $childName?',
              textAlign: TextAlign.start,
            ),
            content: Text(
              isArabic
                  ? 'سيتم حذف حساب الطفل وجميع البيانات المرتبطة به نهائيًا. '
                        'لا يمكن التراجع عن هذا الإجراء.'
                  : 'The child account and all related data will be '
                        'permanently deleted. This action cannot be undone.',
              textAlign: TextAlign.start,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: Text(isArabic ? 'إلغاء' : 'Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                child: Text(isArabic ? 'حذف' : 'Delete'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final dashboardController = context.read<ParentDashboardController>();

    final deleted = await dashboardController.deleteChild(item.child.id);

    if (!context.mounted) return;

    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'تم حذف الطفل بنجاح' : 'Child deleted successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          dashboardController.errorMessage ??
              (isArabic ? 'تعذّر حذف الطفل.' : 'Could not delete the child.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksController = context.watch<ParentChildDetailsController>();

    final isDeleting = context.select<ParentDashboardController, bool>((
      controller,
    ) {
      return controller.isDeletingChild(item.child.id);
    });

    final progress = item.dashboard.progressPercentage.clamp(0, 100).round();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          title: AppPageHeader(
            isArabic: isArabic,
            title: isArabic ? 'بيانات الطفل' : 'Child details',
          ),
        ),
        body: ScreenBackground(
          child: SafeArea(
            top: false,
            child: RefreshIndicator(
              onRefresh: tasksController.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ChildAvatar(
                        avatarIndex: item.child.avatarIndex,
                        size: 92,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      item.child.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isArabic
                          ? '${item.child.age} سنوات'
                          : '${item.child.age} years old',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Row(
                      children: [
                        Expanded(
                          child: _InformationCard(
                            icon: Icons.auto_awesome,
                            value: '${item.points ?? '—'}',
                            label: isArabic ? 'نقاط نور' : 'Noor Points',
                            iconColor: AppColors.gold,
                            backgroundColor: AppColors.goldLight,
                          ),
                        ),

                        const SizedBox(width: AppSpacing.md),

                        Expanded(
                          child: _InformationCard(
                            icon: Icons.trending_up,
                            value: '$progress%',
                            label: isArabic
                                ? 'تقدم الأسبوع'
                                : 'Weekly progress',
                            iconColor: AppColors.primary,
                            backgroundColor: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    _ChildAccessCodeCard(
                      accessCode: item.child.accessCode,
                      isArabic: isArabic,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PointsHistoryScreen(
                              childId: item.child.id,
                              childName: item.child.name,
                              isArabic: isArabic,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: AppColors.primary,
                              ),
                            ),

                            const SizedBox(width: AppSpacing.md),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic
                                        ? 'سجل نقاط نور'
                                        : 'Noor Points History',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    isArabic
                                        ? 'عرض سجل النقاط'
                                        : 'View history points',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              isArabic
                                  ? Icons.arrow_back_ios_new
                                  : Icons.arrow_forward_ios,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DailyFeedbackScreen(
                              child: item.child,
                              isArabic: isArabic,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.sentiment_satisfied_alt,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic
                                        ? 'التقييم اليومي'
                                        : 'Daily Feedback',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isArabic
                                        ? 'قيّمي يوم ${item.child.name} وراجعي السجل'
                                        : 'Rate ${item.child.name}’s day and view history',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isArabic
                                  ? Icons.arrow_back_ios_new
                                  : Icons.arrow_forward_ios,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChildTasksScreen(
                              childId: item.child.id,
                              childName: item.child.name,
                              isArabic: isArabic,
                              controller: tasksController,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.task_alt_outlined,
                                color: AppColors.primary,
                              ),
                            ),

                            const SizedBox(width: AppSpacing.md),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? 'المهام' : 'Tasks',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    isArabic
                                        ? 'عرض مهام ${item.child.name}'
                                        : 'View ${item.child.name}’s tasks',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              isArabic
                                  ? Icons.arrow_back_ios_new
                                  : Icons.arrow_forward_ios,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    const SizedBox(height: AppSpacing.xl),

                    TextButton.icon(
  onPressed: () async {
    final updatedChild = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditChildScreen(
          child: item.child,
          isArabic: isArabic,
        ),
      ),
    );

    if (updatedChild == null || !context.mounted) {
      return;
    }

    final dashboardController =
        context.read<ParentDashboardController>();

    await dashboardController.refresh();

    if (!context.mounted) return;

    Navigator.pop(context, true);
  },
  style: TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(
      vertical: 16,
    ),
  ),
  icon: const Icon(
    Icons.edit_outlined,
  ),
  label: Text(
    isArabic
        ? 'تعديل بيانات الطفل'
        : 'Edit child information',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
),

const Divider(
  color: AppColors.border,
),

const SizedBox(
  height: AppSpacing.md,
),

                   

                    TextButton.icon(
                      onPressed: isDeleting
                          ? null
                          : () {
                              _confirmDelete(context);
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : const Icon(Icons.delete_outline),
                      label: Text(
                        isDeleting
                            ? (isArabic ? 'جارٍ الحذف...' : 'Deleting...')
                            : (isArabic ? 'حذف الطفل' : 'Delete child'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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


class _ChildTaskCard extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final bool isArabic;

  const _ChildTaskCard({required this.assignment, required this.isArabic});

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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
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
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
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

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 13, color: AppColors.gold),
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
    );
  }
}

class _TasksEmptyState extends StatelessWidget {
  final bool isArabic;

  const _TasksEmptyState({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _InformationCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color backgroundColor;

  const _InformationCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildAccessCodeCard extends StatelessWidget {
  final String accessCode;
  final bool isArabic;

  const _ChildAccessCodeCard({
    required this.accessCode,
    required this.isArabic,
  });

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: accessCode));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'تم نسخ رمز دخول الطفل' : 'Child access code copied',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.password_rounded,
              color: AppColors.primaryDark,
              size: 22,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'رمز دخول الطفل' : 'Child access code',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 4),

                SelectableText(
                  accessCode.isEmpty ? '—' : accessCode,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: isArabic ? 'نسخ الرمز' : 'Copy code',
            onPressed: accessCode.isEmpty
                ? null
                : () {
                    _copyCode(context);
                  },
            icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
