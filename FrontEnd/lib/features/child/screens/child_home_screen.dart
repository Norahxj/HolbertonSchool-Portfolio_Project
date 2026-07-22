import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../models/child_model.dart';
import '../../../models/task_assignment_model.dart';
import 'package:frontend/features/child/services/point_api_service.dart';
import '../../../services/task_api_service.dart';
import 'child_task_details_screen.dart';

// The child's home tab.
//
// This screen loads the signed-in child, today's task assignments, and the
// current Noor Points balance. Navigation is handled by ChildNav.
class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  ChildModel? _child;
  List<TaskAssignmentModel> _assignments = [];
  int _points = 0;

  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _updatingAssignments = {};

  Future<void> _loadData({bool showPageLoader = true}) async {
    if (showPageLoader) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final child = await SecureStorage.getChild();
      final assignments = await TaskApiService().getMyAssignments();
      final points = await PointApiService().getMyPoints();

      if (!mounted) return;

      if (child == null) {
        setState(() {
          _errorMessage = 'لم نتمكن من العثور على بيانات الطفل.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _child = child;
        _assignments = assignments;
        _points = points;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل البيانات. حاول مرة أخرى.';
        _isLoading = false;
      });

      debugPrint('Child home loading error: $error');
    }
  }

  Future<void> _completeAssignment(String assignmentId) async {
    setState(() {
      _updatingAssignments.add(assignmentId);
    });

    try {
      await TaskApiService().completeAssignment(assignmentId);
      await _loadData(showPageLoader: false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أحسنت! أُرسلت المهمة إلى ولي أمرك للمراجعة.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر إكمال المهمة. حاول مرة أخرى.')),
      );

      debugPrint('Complete assignment error: $error');
    } finally {
      if (mounted) {
        setState(() {
          _updatingAssignments.remove(assignmentId);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  bool _isFinished(String status) {
    final normalizedStatus = status.toLowerCase();

    return normalizedStatus == 'approved' ||
        normalizedStatus == 'completed' ||
        normalizedStatus == 'pending_review';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _child == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _ErrorState(
          message: _errorMessage ?? 'تعذّر تحميل الصفحة.',
          onRetry: _loadData,
        ),
      );
    }

    final completedCount = _assignments
        .where((assignment) => _isFinished(assignment.status))
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _HomeHeader(
            childName: _child!.name,
            points: _points,
            completedTasks: completedCount,
            totalTasks: _assignments.length,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadData(showPageLoader: false),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DailyGoalCard(
                      completedTasks: completedCount,
                      totalTasks: _assignments.length,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: 'مهام اليوم',
                      count: '${_assignments.length}',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_assignments.isEmpty)
                      const _EmptyTasksCard()
                    else
                      ..._assignments.map(
                        (assignment) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _AssignmentCard(
                            assignment: assignment,
                            isUpdating: _updatingAssignments.contains(
                              assignment.id,
                            ),
                            onComplete:
                                assignment.status.toLowerCase() == 'pending'
                                ? () => _completeAssignment(assignment.id)
                                : null,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChildTaskDetailsScreen(
                                    assignment: assignment,
                                    icon: _categoryStyle(
                                      assignment.task.category,
                                    ).icon,
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              await _loadData(showPageLoader: false);
                            },
                          ),
                        ),
                      ),
                    if (_assignments.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      const _EncouragementCard(),
                    ],
                    const SizedBox(height: AppSpacing.lg),
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

class _HomeHeader extends StatelessWidget {
  final String childName;
  final int points;
  final int completedTasks;
  final int totalTasks;

  const _HomeHeader({
    required this.childName,
    required this.points,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -35,
            left: -20,
            child: _DecorativeBubble(
              size: 110,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -15,
            child: _DecorativeBubble(
              size: 90,
              color: AppColors.gold.withOpacity(0.16),
            ),
          ),
          const Positioned(
            top: 74,
            left: 32,
            child: Icon(Icons.auto_awesome, size: 18, color: AppColors.gold),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'أهلًا يا بطل! 👋',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              childName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.childTitle.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'يوم جديد وإنجازات جديدة بانتظارك',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          color: AppColors.pinkLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withOpacity(0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.child_care_rounded,
                          color: AppColors.pink,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _HeaderMetric(
                          icon: Icons.auto_awesome_rounded,
                          iconColor: AppColors.gold,
                          value: '$points',
                          label: 'نقاط نور',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _HeaderMetric(
                          icon: Icons.task_alt_rounded,
                          iconColor: AppColors.mint,
                          value: '$completedTasks/$totalTasks',
                          label: 'مهام اليوم',
                        ),
                      ),
                    ],
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

class _DecorativeBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeBubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _HeaderMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;

  const _DailyGoalCard({
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks == 0
        ? 0.0
        : (completedTasks / totalTasks).clamp(0.0, 1.0).toDouble();
    final remainingTasks = (totalTasks - completedTasks)
        .clamp(0, totalTasks)
        .toInt();

    String message;

    if (totalTasks == 0) {
      message = 'لا توجد مهام اليوم، استمتع بيومك!';
    } else if (remainingTasks == 0) {
      message = 'رائع! أنجزت جميع مهام اليوم 🎉';
    } else if (remainingTasks == 1) {
      message = 'بقيت لك مهمة واحدة لإكمال هدف اليوم!';
    } else {
      message = 'بقيت لك $remainingTasks مهام لإكمال هدف اليوم';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.goldLight, Color(0xFFFFF9E7)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: AppColors.orange,
                  size: 23,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'هدف اليوم',
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
                    ),
                    Text(
                      message,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$completedTasks/$totalTasks',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation(AppColors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            count,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const Spacer(),
        Text(title, style: AppTextStyles.sectionTitle),
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final VoidCallback? onComplete;
  final VoidCallback onTap;
  final bool isUpdating;

  const _AssignmentCard({
    required this.assignment,
    required this.onTap,
    required this.isUpdating,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final category = _categoryStyle(assignment.task.category);
    final status = _statusStyle(assignment.status);
    final canComplete =
        assignment.status.toLowerCase() == 'pending' && onComplete != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: category.color.withOpacity(0.28),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: category.color.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: category.background,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(category.icon, color: category.color, size: 25),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      assignment.task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: category.color,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _SmallBadge(
                          icon: status.icon,
                          text: status.label,
                          foreground: status.color,
                          background: status.background,
                        ),
                        _SmallBadge(
                          icon: Icons.auto_awesome_rounded,
                          text: '${assignment.task.points} نقاط',
                          foreground: const Color(0xFFB77700),
                          background: AppColors.goldLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _TaskActionButton(
                isUpdating: isUpdating,
                canComplete: canComplete,
                status: status,
                onTap: onComplete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskActionButton extends StatelessWidget {
  final bool isUpdating;
  final bool canComplete;
  final _StatusStyle status;
  final VoidCallback? onTap;

  const _TaskActionButton({
    required this.isUpdating,
    required this.canComplete,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isUpdating) {
      return const SizedBox(
        width: 38,
        height: 38,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    return Material(
      color: canComplete ? AppColors.primary : status.background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: canComplete ? onTap : null,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            canComplete ? Icons.check_rounded : status.icon,
            color: canComplete ? Colors.white : status.color,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color foreground;
  final Color background;

  const _SmallBadge({
    required this.icon,
    required this.text,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTasksCard extends StatelessWidget {
  const _EmptyTasksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.skyLight,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.sky.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: AppColors.sky,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('لا توجد مهام اليوم', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text(
            'استمتع بوقتك، وعد لاحقًا لرؤية مهام جديدة.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

class _EncouragementCard extends StatelessWidget {
  const _EncouragementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.mintLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: AppColors.mint, size: 30),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'كل مهمة تنجزها تقرّبك من هدف جديد ومكافأة أجمل!',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  color: AppColors.coralLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.coral,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => onRetry(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryStyle {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _CategoryStyle({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
}

_CategoryStyle _categoryStyle(String? category) {
  switch (category?.toLowerCase()) {
    case 'religious':
      return const _CategoryStyle(
        label: 'قيمة دينية',
        icon: Icons.mosque_rounded,
        color: AppColors.primaryDark,
        background: AppColors.primaryLight,
      );
    case 'financial':
      return const _CategoryStyle(
        label: 'مهارة مالية',
        icon: Icons.monetization_on_rounded,
        color: Color(0xFFB77700),
        background: AppColors.goldLight,
      );
    case 'moral':
      return const _CategoryStyle(
        label: 'قيمة أخلاقية',
        icon: Icons.volunteer_activism_rounded,
        color: AppColors.pink,
        background: AppColors.pinkLight,
      );
    case 'social':
      return const _CategoryStyle(
        label: 'مهمة اجتماعية',
        icon: Icons.groups_rounded,
        color: AppColors.sky,
        background: AppColors.skyLight,
      );
    default:
      return const _CategoryStyle(
        label: 'مهمة يومية',
        icon: Icons.task_alt_rounded,
        color: AppColors.mint,
        background: AppColors.mintLight,
      );
  }
}

class _StatusStyle {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatusStyle({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
}

_StatusStyle _statusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return const _StatusStyle(
        label: 'تم الاعتماد',
        icon: Icons.verified_rounded,
        color: AppColors.mint,
        background: AppColors.mintLight,
      );
    case 'completed':
    case 'pending_review':
      return const _StatusStyle(
        label: 'بانتظار المراجعة',
        icon: Icons.hourglass_top_rounded,
        color: AppColors.orange,
        background: AppColors.orangeLight,
      );
    case 'rejected':
      return const _StatusStyle(
        label: 'حاول مرة أخرى',
        icon: Icons.refresh_rounded,
        color: AppColors.coral,
        background: AppColors.coralLight,
      );
    case 'pending':
    default:
      return const _StatusStyle(
        label: 'جاهزة للإنجاز',
        icon: Icons.play_arrow_rounded,
        color: AppColors.sky,
        background: AppColors.skyLight,
      );
  }
}
