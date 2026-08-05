import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/child_avatar.dart';
import '../../../../core/widgets/screen_background.dart';
import '../../parent_child_details/controllers/parent_child_details_controller.dart';
import '../../dashboard/controllers/parent_dashboard_controller.dart';
import '../../dashboard/models/parent_dashboard_data.dart';
import '../../child_tasks/screens/child_tasks_screen.dart';
import '../../daily_feedback/screens/daily_feedback_screen.dart';
import '../../edit_child/screens/edit_child_screen.dart';
import '../../points_history/screens/points_history_screen.dart';
import 'child_access_code_card.dart';
import 'child_details_navigation_card.dart';
import 'information_card.dart';

class ParentChildDetailsView extends StatelessWidget {
  final ParentDashboardChildItem item;
  final bool isArabic;

  const ParentChildDetailsView({
    super.key,
    required this.item,
    required this.isArabic,
  });

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

    if (!context.mounted) {
      return;
    }

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

  Future<void> _openEditChild(BuildContext context) async {
    final updatedChild = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditChildScreen(child: item.child, isArabic: isArabic),
      ),
    );

    if (updatedChild == null || !context.mounted) {
      return;
    }

    final dashboardController = context.read<ParentDashboardController>();

    await dashboardController.refresh();

    if (!context.mounted) {
      return;
    }

    Navigator.pop(context, true);
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
                          child: InformationCard(
                            icon: Icons.auto_awesome,
                            value: '${item.points ?? '—'}',
                            label: isArabic ? 'نقاط نور' : 'Noor Points',
                            iconColor: AppColors.gold,
                            backgroundColor: AppColors.goldLight,
                          ),
                        ),

                        const SizedBox(width: AppSpacing.md),

                        Expanded(
                          child: InformationCard(
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

                    ChildAccessCodeCard(
                      accessCode: item.child.accessCode,
                      isArabic: isArabic,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    ChildDetailsNavigationCard(
                      icon: Icons.history,
                      title: isArabic ? 'سجل نقاط نور' : 'Noor Points History',
                      subtitle: isArabic
                          ? 'عرض سجل النقاط'
                          : 'View history points',
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
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    ChildDetailsNavigationCard(
                      icon: Icons.sentiment_satisfied_alt,
                      title: isArabic ? 'التقييم اليومي' : 'Daily Feedback',
                      subtitle: isArabic
                          ? 'قيّمي يوم ${item.child.name} وراجعي السجل'
                          : 'Rate ${item.child.name}’s day and view history',
                      backgroundColor: Colors.white,
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
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    ChildDetailsNavigationCard(
                      icon: Icons.task_alt_outlined,
                      title: isArabic ? 'المهام' : 'Tasks',
                      subtitle: isArabic
                          ? 'عرض مهام ${item.child.name}'
                          : 'View ${item.child.name}’s tasks',
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
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    TextButton.icon(
                      onPressed: () {
                        _openEditChild(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(
                        isArabic
                            ? 'تعديل بيانات الطفل'
                            : 'Edit child information',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const Divider(color: AppColors.border),

                    const SizedBox(height: AppSpacing.md),

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
