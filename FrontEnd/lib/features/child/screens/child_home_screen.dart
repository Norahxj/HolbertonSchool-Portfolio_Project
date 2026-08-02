import 'package:flutter/material.dart';
import '../../../app.dart';
import '../../auth/services/auth_api_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../models/child_model.dart';
import '../../../models/task_assignment_model.dart';
import 'package:frontend/features/child/services/point_api_service.dart';
import '../../../services/task_api_service.dart';
import 'child_task_details_screen.dart';
import 'child_settings_screen.dart';
import '../../../models/daily_feedback_model.dart';
import '../../../services/daily_feedback_api_service.dart';
import '../../../core/widgets/child_avatar.dart';
import '../../../core/widgets/screen_background.dart';

// The child's home tab.
//
// This screen loads the signed-in child, today's task assignments, and the
// current Noor Points balance. Navigation is handled by ChildNav.
class ChildHomeScreen extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;

  const ChildHomeScreen({
    super.key,
    required this.isArabic,
    required this.onLanguageToggle,
  });

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  ChildModel? _child;
  List<TaskAssignmentModel> _assignments = [];
  DailyFeedbackModel? _todayFeedback;
  int _points = 0;

  final DailyFeedbackApiService _feedbackService = DailyFeedbackApiService();
  final TaskApiService _taskApiService = TaskApiService();
  final PointApiService _pointApiService = PointApiService();
  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _updatingAssignments = {};
  Future<void> _loadTodayFeedback() async {
  try {
    final feedback =
        await _feedbackService.getMyTodayFeedback();

    if (!mounted) return;

    setState(() {
      _todayFeedback = feedback;
    });
  } catch (error) {
    debugPrint(
      'Today feedback loading error: $error',
    );
  }
}

  Future<void> _loadData({
  bool showPageLoader = true,
}) async {
  if (showPageLoader) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  try {
    final childFuture = SecureStorage.getChild();

    final assignmentsFuture =
        _taskApiService.getMyCurrentWeekAssignments();

    final pointsFuture =
        _pointApiService.getMyPoints();

    final results = await Future.wait([
      childFuture,
      assignmentsFuture,
      pointsFuture,
    ]);

    final child = results[0] as ChildModel?;

    final assignments =
        results[1] as List<TaskAssignmentModel>;

    final points = results[2] as int;

    if (!mounted) return;

    if (child == null) {
      setState(() {
        _errorMessage = widget.isArabic
            ? 'لم نتمكن من العثور على بيانات الطفل.'
            : 'We could not find the child\'s information.';

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

    _loadTodayFeedback();
  } catch (error) {
    if (!mounted) return;

    setState(() {
      _errorMessage = widget.isArabic
          ? 'حدث خطأ أثناء تحميل البيانات. حاول مرة أخرى.'
          : 'An error occurred while loading the data. Please try again.';

      _isLoading = false;
    });

    debugPrint('Child home loading error: $error');
  }
}

  Future<void> _refreshTasksAndPoints() async {
    try {
      final results = await Future.wait([
_taskApiService.getMyCurrentWeekAssignments(),
        _pointApiService.getMyPoints(),
      ]);

      if (!mounted) return;

      setState(() {
        _assignments = results[0] as List<TaskAssignmentModel>;
        _points = results[1] as int;
      });
    } catch (error) {
      debugPrint('Tasks and points refresh error: $error');
    }
  }

  Future<void> _completeAssignment(String assignmentId) async {
    setState(() {
      _updatingAssignments.add(assignmentId);
    });

    try {
      await _taskApiService.completeAssignment(assignmentId);
      await _refreshTasksAndPoints();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isArabic
                ? 'أحسنت! أُرسلت المهمة إلى ولي أمرك للمراجعة.'
                : 'Well done! The task was sent to your guardian for review.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isArabic
                ? 'تعذّر إكمال المهمة. حاول مرة أخرى.'
                : 'The task could not be completed. Please try again.',
          ),
        ),
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

  Future<void> _logout() async {
    await AuthApiService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AsalahApp()),
      (route) => false,
    );
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
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_errorMessage != null || _child == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: _ErrorState(
            message:
                _errorMessage ??
                (widget.isArabic
                    ? 'تعذّر تحميل الصفحة.'
                    : 'The page could not be loaded.'),
            onRetry: _loadData,
            isArabic: widget.isArabic,
          ),
        ),
      );
    }

    final completedCount = _assignments
        .where((assignment) => _isFinished(assignment.status))
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: Column(
          children: [
            _HomeHeader(
              childName: _child!.name,
              avatarIndex: _child!.avatarIndex,
              points: _points,
              completedTasks: completedCount,
              totalTasks: _assignments.length,
              isArabic: widget.isArabic,
              onSettingsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChildSettingsScreen(
                      childName: _child!.name,
                      avatarIndex: _child!.avatarIndex,
                      isArabic: widget.isArabic,
                      onLanguageToggle: widget.onLanguageToggle,
                      onLogout: _logout,
                    ),
                  ),
                );
              },
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
                        isArabic: widget.isArabic,
                      ),
                      if (_todayFeedback != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _DailyFeedbackCard(
                          feedback: _todayFeedback!,
                          isArabic: widget.isArabic,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      _SectionHeader(
                        title: widget.isArabic
                            ? 'مهام اليوم'
                            : 'Today\'s Tasks',
                        count: '${_assignments.length}',
                        isArabic: widget.isArabic,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_assignments.isEmpty)
                        _EmptyTasksCard(isArabic: widget.isArabic)
                      else
                        ..._assignments.map(
                          (assignment) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: _AssignmentCard(
                              assignment: assignment,
                              isArabic: widget.isArabic,
                              isUpdating: _updatingAssignments.contains(
                                assignment.id,
                              ),
                              onComplete:
                                  assignment.status.toLowerCase() ==
                                          'pending' ||
                                      assignment.status.toLowerCase() ==
                                          'rejected'
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
                                        widget.isArabic,
                                      ).icon,
                                      isArabic: widget.isArabic,
                                    ),
                                  ),
                                );

                                if (!mounted) return;

                                await _refreshTasksAndPoints();
                              },
                            ),
                          ),
                        ),
                      if (_assignments.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _EncouragementCard(isArabic: widget.isArabic),
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

class _HomeHeader extends StatelessWidget {
  final String childName;
  final int avatarIndex;
  final int points;
  final int completedTasks;
  final int totalTasks;
  final bool isArabic;
  final VoidCallback onSettingsPressed;

  const _HomeHeader({
    required this.childName,
    required this.avatarIndex,
    required this.points,
    required this.completedTasks,
    required this.totalTasks,
    required this.isArabic,
    required this.onSettingsPressed,
  });

  /// Avatar indices 0 and 1 are boy avatars.
  /// Avatar indices 2 and 3 are girl avatars.
  bool get isGirlAvatar {
    return avatarIndex == 2 || avatarIndex == 3;
  }

  String get greeting {
    if (!isArabic) {
      return 'Hello, champion! 👋';
    }

    return isGirlAvatar ? 'أهلًا يا بطلة! 👋' : 'أهلًا يا بطل! 👋';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = isArabic
        ? 'يوم جديد وإنجازات جديدة بانتظارك'
        : 'A new day and new achievements await you';

    final pointsLabel = isArabic ? 'نقاط نور' : 'Noor Points';

    final tasksLabel = isArabic ? 'مهام اليوم' : 'Today\'s Tasks';

    final settingsLabel = isArabic ? 'الإعدادات' : 'Settings';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(36),
            bottomRight: Radius.circular(36),
          ),
          image: DecorationImage(
            image: AssetImage('assets/dashboard/child_home_background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6F42C1).withValues(alpha: 0.30),
                      const Color(0xFF7F55D9).withValues(alpha: 0.52),
                    ],
                  ),
                ),
              ),
            ),

            PositionedDirectional(
              top: -35,
              start: -20,
              child: _DecorativeBubble(
                size: 110,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),

            PositionedDirectional(
              bottom: -30,
              end: -15,
              child: _DecorativeBubble(
                size: 90,
                color: AppColors.gold.withValues(alpha: 0.16),
              ),
            ),

            Positioned(
              top: 145,
              left: 54,
              child: Icon(
                Icons.star_rounded,
                size: 13,
                color: Colors.white.withValues(alpha: 0.70),
              ),
            ),

            Positioned(
              top: 8,
              left: isArabic ? 12 : null,
              right: isArabic ? null : 12,
              child: SafeArea(
                bottom: false,
                child: IconButton(
                  tooltip: settingsLabel,
                  onPressed: onSettingsPressed,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                  ),
                  icon: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  6,
                  AppSpacing.lg,
                  10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 86,
                        height: 86,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.45),
                              blurRadius: 18,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: AppColors.primaryDark.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ChildAvatar(avatarIndex: avatarIndex, size: 78),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      greeting,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 1),

                    Text(
                      childName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.childTitle.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),

                    const SizedBox(height: 2),

                    /*
                     * The text is placed first in the Row.
                     *
                     * In Arabic, RTL places the text on the right and
                     * the glitter directly after it on the left.
                     *
                     * In English, LTR places the text on the left and
                     * the glitter directly after it on the right.
                     */
                    Directionality(
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          const Icon(
                            Icons.auto_awesome,
                            color: AppColors.gold,
                            size: 15,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _HeaderMetric(
                            icon: Icons.auto_awesome_rounded,
                            iconColor: AppColors.gold,
                            value: '$points',
                            label: pointsLabel,
                            isArabic: isArabic,
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        Expanded(
                          child: _HeaderMetric(
                            icon: Icons.task_alt_rounded,
                            iconColor: AppColors.mint,
                            value: '$completedTasks/$totalTasks',
                            label: tasksLabel,
                            isArabic: isArabic,
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
  final bool isArabic;

  const _HeaderMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha:0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.07),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha:0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),

          const SizedBox(width: 10),

          Flexible(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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

class _DailyFeedbackCard extends StatelessWidget {
  final DailyFeedbackModel feedback;
  final bool isArabic;

  const _DailyFeedbackCard({required this.feedback, required this.isArabic});

  String get _emoji {
    switch (feedback.mood) {
      case 'HAPPY':
        return '😊';
      case 'PROUD':
        return '🌟';
      case 'GREAT':
        return '🎉';
      case 'LOVE':
        return '❤️';
      case 'STRONG':
        return '💪';
      case 'STAR':
        return '⭐';
      default:
        return '🌟';
    }
  }

  String get _label {
    if (isArabic) {
      switch (feedback.mood) {
        case 'HAPPY':
          return 'سعيد';
        case 'PROUD':
          return 'فخور بك';
        case 'GREAT':
          return 'رائع';
        case 'LOVE':
          return 'محبوب';
        case 'STRONG':
          return 'قوي';
        case 'STAR':
          return 'نجم';
        default:
          return feedback.mood;
      }
    }

    switch (feedback.mood) {
      case 'HAPPY':
        return 'Happy';
      case 'PROUD':
        return 'Proud of you';
      case 'GREAT':
        return 'Great';
      case 'LOVE':
        return 'Loved';
      case 'STRONG':
        return 'Strong';
      case 'STAR':
        return 'Star';
      default:
        return feedback.mood;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha:0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(_emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'تشجيع اليوم' : 'Today\'s Encouragement',
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  _label,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 2),
                Text(
                  isArabic ? 'من العائلة' : 'From your family',
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final bool isArabic;

  const _DailyGoalCard({
    required this.completedTasks,
    required this.totalTasks,
    required this.isArabic,
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
      message = isArabic
          ? 'لا توجد مهام اليوم، استمتع بيومك!'
          : 'There are no tasks today. Enjoy your day!';
    } else if (remainingTasks == 0) {
      message = isArabic
          ? 'رائع! أنجزت جميع مهام اليوم 🎉'
          : 'Great! You completed all of today\'s tasks 🎉';
    } else if (remainingTasks == 1) {
      message = isArabic
          ? 'بقيت لك مهمة واحدة لإكمال هدف اليوم!'
          : 'You have one task left to complete today\'s goal!';
    } else {
      message = isArabic
          ? 'بقيت لك $remainingTasks مهام لإكمال هدف اليوم'
          : 'You have $remainingTasks tasks left to complete today\'s goal';
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
        border: Border.all(color: AppColors.gold.withValues(alpha:0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha:0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: AppColors.orange,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  Text(
                    isArabic ? 'هدف اليوم' : 'Today\'s Goal',
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
                  ),
                ],
              ),

              const Spacer(),

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

          const SizedBox(height: 6),

          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              message,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: AppTextStyles.caption,
            ),
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
  final bool isArabic;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),

        const Spacer(),

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
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final VoidCallback? onComplete;
  final VoidCallback onTap;
  final bool isUpdating;
  final bool isArabic;

  const _AssignmentCard({
    required this.assignment,
    required this.onTap,
    required this.isUpdating,
    required this.isArabic,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final category = _categoryStyle(assignment.task.category, isArabic);

    final status = _statusStyle(assignment.status, isArabic);
    final normalizedStatus = assignment.status.toLowerCase();

    final canComplete =
        (normalizedStatus == 'pending' || normalizedStatus == 'rejected') &&
        onComplete != null;

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
              color: category.color.withValues(alpha:0.28),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: category.color.withValues(alpha:0.10),
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
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      alignment: isArabic
                          ? WrapAlignment.end
                          : WrapAlignment.start,
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
                          text: isArabic
                              ? '${assignment.task.points} نقاط'
                              : '${assignment.task.points} points',
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
  final bool isArabic;
  const _EmptyTasksCard({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.skyLight,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.sky.withValues(alpha:0.25)),
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
          Text(
            isArabic ? 'لا توجد مهام اليوم' : 'No tasks today',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 4),
          Text(
            isArabic
                ? 'استمتع بوقتك، وعد لاحقًا لرؤية مهام جديدة.'
                : 'Enjoy your time and come back later for new tasks.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

class _EncouragementCard extends StatelessWidget {
  final bool isArabic;
  const _EncouragementCard({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.mintLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: AppColors.mint, size: 30),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              isArabic
                  ? 'كل مهمة تنجزها تقرّبك من هدف جديد ومكافأة أجمل!'
                  : 'Every task you complete brings you closer to a new goal and a better reward!',
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
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
  final bool isArabic;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.isArabic,
  });

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
                label: Text(isArabic ? 'إعادة المحاولة' : 'Try Again'),
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

_CategoryStyle _categoryStyle(String? category, bool isArabic) {
  switch (category?.toLowerCase()) {
    case 'religious':
      return _CategoryStyle(
        label: isArabic ? 'قيمة دينية' : 'Religious Value',
        icon: Icons.mosque_rounded,
        color: AppColors.primaryDark,
        background: AppColors.primaryLight,
      );
    case 'financial':
      return _CategoryStyle(
        label: isArabic ? 'مهارة مالية' : 'Financial Skill',
        icon: Icons.monetization_on_rounded,
        color: Color(0xFFB77700),
        background: AppColors.goldLight,
      );
    case 'moral':
      return _CategoryStyle(
        label: isArabic ? 'قيمة أخلاقية' : 'Moral Value',
        icon: Icons.volunteer_activism_rounded,
        color: AppColors.pink,
        background: AppColors.pinkLight,
      );
    case 'social':
      return _CategoryStyle(
        label: isArabic ? 'مهمة اجتماعية' : 'Social Task',
        icon: Icons.groups_rounded,
        color: AppColors.sky,
        background: AppColors.skyLight,
      );
    default:
      return _CategoryStyle(
        label: isArabic ? 'مهمة يومية' : 'Daily Task',
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

_StatusStyle _statusStyle(String status, bool isArabic) {
  switch (status.toLowerCase()) {
    case 'approved':
      return _StatusStyle(
        label: isArabic ? 'تم الاعتماد' : 'Approved',
        icon: Icons.verified_rounded,
        color: AppColors.mint,
        background: AppColors.mintLight,
      );
    case 'completed':
    case 'pending_review':
      return _StatusStyle(
        label: isArabic ? 'بانتظار المراجعة' : 'Waiting for Review',
        icon: Icons.hourglass_top_rounded,
        color: AppColors.orange,
        background: AppColors.orangeLight,
      );
    case 'rejected':
      return _StatusStyle(
        label: isArabic ? 'حاول مرة أخرى' : 'Try Again',
        icon: Icons.refresh_rounded,
        color: AppColors.coral,
        background: AppColors.coralLight,
      );
    case 'pending':
    default:
      return _StatusStyle(
        label: isArabic ? 'جاهزة للإنجاز' : 'Ready',
        icon: Icons.play_arrow_rounded,
        color: AppColors.sky,
        background: AppColors.skyLight,
      );
  }
}
