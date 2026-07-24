import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/task_assignment_model.dart';
import '../../../services/task_api_service.dart';
import '../services/point_api_service.dart';

class ChildProgressScreen extends StatefulWidget {
  const ChildProgressScreen({super.key});

  @override
  State<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends State<ChildProgressScreen> {
  final TaskApiService _taskApiService = TaskApiService();

  final PointApiService _pointApiService = PointApiService();

  List<TaskAssignmentModel> _assignments = [];

  int _points = 0;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final assignments = await _taskApiService.getMyAssignments();

      final points = await _pointApiService.getMyPoints();

      if (!mounted) return;

      setState(() {
        _assignments = assignments;
        _points = points;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'تعذّر تحميل بيانات التقدم.';
        _isLoading = false;
      });

      debugPrint('Progress loading error: $error');
    }
  }

  DateTime get _today {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _weekStart {
    final daysFromSunday = _today.weekday % 7;

    return _today.subtract(Duration(days: daysFromSunday));
  }

  DateTime get _weekEnd {
    return _weekStart.add(const Duration(days: 7));
  }

  bool _isInsideCurrentWeek(DateTime date) {
    final localDate = date.toLocal();

    return !localDate.isBefore(_weekStart) && localDate.isBefore(_weekEnd);
  }

  DateTime? _completionDate(TaskAssignmentModel assignment) {
    return assignment.completedAt?.toLocal() ??
        assignment.approvedAt?.toLocal();
  }

  List<TaskAssignmentModel> get _weeklyAssignments {
    return _assignments.where((assignment) {
      return _isInsideCurrentWeek(assignment.assignedDate);
    }).toList();
  }

  int get _weeklyCompleted {
    return _weeklyAssignments.where((assignment) {
      return assignment.countsTowardProgress;
    }).length;
  }

  int get _weeklyPercent {
    if (_weeklyAssignments.isEmpty) {
      return 0;
    }

    return ((_weeklyCompleted / _weeklyAssignments.length) * 100).round().clamp(
      0,
      100,
    );
  }

  int get _totalCompleted {
    return _assignments.where((assignment) {
      return assignment.countsTowardProgress;
    }).length;
  }

  String _dateKey(DateTime date) {
    final local = date.toLocal();

    return '${local.year}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  int get _currentStreak {
    final completionDays = <String>{};

    for (final assignment in _assignments) {
      if (!assignment.countsTowardProgress) {
        continue;
      }

      final date = _completionDate(assignment);

      if (date != null) {
        completionDays.add(_dateKey(date));
      }
    }

    if (completionDays.isEmpty) {
      return 0;
    }

    DateTime currentDay;

    if (completionDays.contains(_dateKey(_today))) {
      currentDay = _today;
    } else {
      final yesterday = _today.subtract(const Duration(days: 1));

      if (!completionDays.contains(_dateKey(yesterday))) {
        return 0;
      }

      currentDay = yesterday;
    }

    int streak = 0;

    while (completionDays.contains(_dateKey(currentDay))) {
      streak++;

      currentDay = currentDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  List<int> get _weeklyActivity {
    final counts = List<int>.filled(7, 0);

    for (final assignment in _assignments) {
      if (!assignment.countsTowardProgress) {
        continue;
      }

      final completionDate = _completionDate(assignment);

      if (completionDate == null || !_isInsideCurrentWeek(completionDate)) {
        continue;
      }

      final index = completionDate.weekday % 7;

      counts[index]++;
    }

    return counts;
  }

  Map<_TrophyKind, int> get _completedByCategory {
    final counts = <_TrophyKind, int>{
      _TrophyKind.daily: 0,
      _TrophyKind.cultural: 0,
      _TrophyKind.financial: 0,
      _TrophyKind.religious: 0,
    };

    for (final assignment in _assignments) {
      if (!assignment.countsTowardProgress) {
        continue;
      }

      final kind = _categoryKind(assignment.task.category);

      counts[kind] = (counts[kind] ?? 0) + 1;
    }

    return counts;
  }

  _TrophyKind _categoryKind(String? category) {
    switch (category?.toUpperCase()) {
      case 'RELIGIOUS':
        return _TrophyKind.religious;

      case 'FINANCIAL':
        return _TrophyKind.financial;

      case 'CULTURAL':
      case 'SOCIAL':
        return _TrophyKind.cultural;

      case 'DAILY':
      case 'MORAL':
      default:
        return _TrophyKind.daily;
    }
  }

  String get _progressMessage {
    if (_weeklyAssignments.isEmpty) {
      return 'لا توجد مهام مسندة هذا الأسبوع';
    }

    if (_weeklyCompleted == _weeklyAssignments.length) {
      return 'رائع! أنجزت جميع مهام هذا الأسبوع';
    }

    return 'أحسنت! أنجزت $_weeklyCompleted '
        'من ${_weeklyAssignments.length} مهام هذا الأسبوع';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _ProgressErrorState(message: _errorMessage!, onRetry: _loadData),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'تقدّمي',
                  style: AppTextStyles.arabicTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

                _ProgressSummaryCard(
                  percent: _weeklyPercent,
                  message: _progressMessage,
                ),

                const SizedBox(height: AppSpacing.lg),

                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.water_drop,
                        iconColor: const Color(0xFFDE9A3E),
                        value: '$_currentStreak',
                        label: 'أيام متتالية',
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    Expanded(
                      child: _StatTile(
                        icon: Icons.check_circle_outline,
                        iconColor: AppColors.success,
                        value: '$_totalCompleted',
                        label: 'مهمة مكتملة',
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    Expanded(
                      child: _StatTile(
                        icon: Icons.auto_awesome,
                        iconColor: AppColors.gold,
                        value: '$_points',
                        label: 'رصيد النقاط',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                _TrophiesSection(completedByCategory: _completedByCategory),

                const SizedBox(height: AppSpacing.xl),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'نشاط الأسبوع',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                _WeeklyBarChart(activity: _weeklyActivity),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  final int percent;
  final String message;

  const _ProgressSummaryCard({required this.percent, required this.message});

  @override
  Widget build(BuildContext context) {
    final safePercent = percent.clamp(0, 100);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: safePercent / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    ),
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$safePercent%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 2),

                      const Text(
                        'هذا الأسبوع',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),

          const SizedBox(height: AppSpacing.sm),

          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 2),

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

enum _TrophyKind { daily, cultural, financial, religious }

class _TrophiesSection extends StatelessWidget {
  final Map<_TrophyKind, int> completedByCategory;

  const _TrophiesSection({required this.completedByCategory});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'أوسمتي',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _TrophyBadge(
                  kind: _TrophyKind.daily,
                  completedTasks: completedByCategory[_TrophyKind.daily] ?? 0,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: _TrophyBadge(
                  kind: _TrophyKind.cultural,
                  completedTasks:
                      completedByCategory[_TrophyKind.cultural] ?? 0,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: _TrophyBadge(
                  kind: _TrophyKind.financial,
                  completedTasks:
                      completedByCategory[_TrophyKind.financial] ?? 0,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: _TrophyBadge(
                  kind: _TrophyKind.religious,
                  completedTasks:
                      completedByCategory[_TrophyKind.religious] ?? 0,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          const Text(
            'يفتح كل وسام بعد إنجاز 5 مهام من فئته',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TrophyBadge extends StatelessWidget {
  final _TrophyKind kind;
  final int completedTasks;

  const _TrophyBadge({required this.kind, required this.completedTasks});

  bool get unlocked {
    return completedTasks >= 5;
  }

  int get displayedTasks {
    return completedTasks > 5 ? 5 : completedTasks;
  }

  String get title {
    switch (kind) {
      case _TrophyKind.daily:
        return 'المهام\nاليومية';

      case _TrophyKind.cultural:
        return 'المهام\nالثقافية';

      case _TrophyKind.financial:
        return 'المهام\nالمالية';

      case _TrophyKind.religious:
        return 'المهام\nالدينية';
    }
  }

  IconData get categoryIcon {
    switch (kind) {
      case _TrophyKind.daily:
        return Icons.wb_sunny_rounded;

      case _TrophyKind.cultural:
        return Icons.menu_book_rounded;

      case _TrophyKind.financial:
        return Icons.savings_rounded;

      case _TrophyKind.religious:
        return Icons.nightlight_round;
    }
  }

  Color get accentColor {
    if (!unlocked) {
      return const Color(0xFFB8ACD8);
    }

    switch (kind) {
      case _TrophyKind.daily:
        return const Color(0xFFE2B640);

      case _TrophyKind.cultural:
        return const Color(0xFF8C6CDD);

      case _TrophyKind.financial:
        return const Color(0xFF65B98B);

      case _TrophyKind.religious:
        return const Color(0xFFE29B4A);
    }
  }

  Color get cardBackground {
    return unlocked ? const Color(0xFFFFFCF3) : const Color(0xFFF8F5FC);
  }

  Color get cardBorder {
    return unlocked ? accentColor : const Color(0xFFE7E0F2);
  }

  @override
  Widget build(BuildContext context) {
    const lockedTextColor = Color(0xFF9E95B9);

    return Container(
      height: 165,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: cardBorder, width: unlocked ? 2 : 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: unlocked ? 0.16 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(
                      alpha: unlocked ? 0.17 : 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),

                Icon(Icons.emoji_events_rounded, size: 36, color: accentColor),

                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: unlocked ? Colors.white : const Color(0xFFF0ECF7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(categoryIcon, size: 14, color: accentColor),
                  ),
                ),

                if (!unlocked)
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Color(0xFFE9E3F4),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 11,
                        color: lockedTextColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.3,
              fontWeight: FontWeight.bold,
              color: unlocked ? AppColors.textPrimary : lockedTextColor,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: unlocked ? 0.13 : 0.09),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              unlocked
                  ? 'مكتمل ٥/٥'
                  : '${_convertToArabicNumbers(displayedTasks)}/٥',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: unlocked ? accentColor : lockedTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _convertToArabicNumbers(int number) {
  const englishNumbers = '0123456789';
  const arabicNumbers = '٠١٢٣٤٥٦٧٨٩';

  return number.toString().split('').map((character) {
    final index = englishNumbers.indexOf(character);

    if (index == -1) {
      return character;
    }

    return arabicNumbers[index];
  }).join();
}

class _WeeklyBarChart extends StatelessWidget {
  final List<int> activity;

  const _WeeklyBarChart({required this.activity});

  @override
  Widget build(BuildContext context) {
    const labels = ['أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];

    int maximum = 0;

    for (final value in activity) {
      if (value > maximum) {
        maximum = value;
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final count = index < activity.length ? activity[index] : 0;

            final height = maximum == 0 ? 8.0 : 8.0 + (count / maximum) * 70;

            return _DayBar(
              label: labels[index],
              count: count,
              height: height,
              isMostActive: maximum > 0 && count == maximum,
            );
          }),
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final String label;
  final int count;
  final double height;
  final bool isMostActive;

  const _DayBar({
    required this.label,
    required this.count,
    required this.height,
    required this.isMostActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 4),

        Container(
          width: 22,
          height: height,
          decoration: BoxDecoration(
            color: isMostActive ? AppColors.primary : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ProgressErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ProgressErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.insights_rounded,
                size: 54,
                color: AppColors.primary,
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionTitle,
              ),

              const SizedBox(height: AppSpacing.md),

              ElevatedButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
