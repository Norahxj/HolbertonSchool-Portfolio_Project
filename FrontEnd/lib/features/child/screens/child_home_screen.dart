import 'package:flutter/material.dart';
import 'package:frontend/models/child_model.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import 'child_progress_screen.dart';
import 'child_rewards_screen.dart';
import 'child_task_details_screen.dart';
import 'child_wishlist_screen.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../models/task_assignment_model.dart';
import '../../../services/task_api_service.dart';
import '../../../services/point_api_service.dart';

// Child Home Dashboard screen (Screen 21).
//

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});
  

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
int _currentTab = 0;

ChildModel? _child;
List<TaskAssignmentModel> _assignments = [];
int _points = 0;
bool _isLoading = true;
String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final child = await SecureStorage.getChild();
    final assignments = await TaskApiService().getMyAssignments();
    final points = await PointApiService().getMyPoints();

    if (!mounted) return;

    setState(() {
      _child = child;
      _assignments = assignments;
      _points = points;
      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _error = e.toString();
      _isLoading = false;
    });
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: IndexedStack(
      index: _currentTab,
      children: [
        _buildHomeTab(),
        const ChildWishlistScreen(),
        const ChildRewardsScreen(),
        const ChildProgressScreen(),
      ],
    ),
    bottomNavigationBar: _BottomNavBar(
      currentIndex: _currentTab,
      onTap: (index) {
        setState(() {
          _currentTab = index;
        });
      },
    ),
  );
}
// Purple gradient header: greeting, avatar, and the Noor points card.
Widget _buildHomeTab() {
  if (_isLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (_error != null) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'حدث خطأ أثناء تحميل البيانات',
            style: AppTextStyles.arabicTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _loadData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  return Column(
    children: [
      _HomeHeader(
        childName: _child?.name ?? '',
        points: _points,
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        '${_assignments.where((assignment) {
                          final status = assignment.status.toLowerCase();
                          return status == 'approved' || status == 'pending_review';
                        }).length}/${_assignments.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    Text(
                      'مهام اليوم',
                      style: AppTextStyles.arabicTitle,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (_assignments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'لا توجد مهام اليوم 🎉',
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ..._assignments.map(
                    (assignment) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.md,
                        ),
                        child: _AssignmentCard(
                          assignment: assignment,
                          onComplete: assignment.status.toLowerCase() == 'pending'
                              ? () async {
                                  try {
                                    await TaskApiService()
                                        .completeAssignment(assignment.id);
                                    await _loadData();
                                  } catch (e) {
                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'تعذر إكمال المهمة',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChildTaskDetailsScreen(
                                  title: assignment.task.title,
                                  points: assignment.task.points,
                                  description:
                                      assignment.task.description,
                                  frequencyLabel:
                                      assignment.task.taskFrequency,
                                  icon: _categoryIcon(
                                    assignment.task.category,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

IconData _categoryIcon(String? category) {
  switch (category?.toLowerCase()) {
    case 'religious':
      return Icons.mosque;

    case 'financial':
      return Icons.credit_card;

    case 'moral':
      return Icons.volunteer_activism;

    case 'social':
      return Icons.groups;

    default:
      return Icons.task_alt;
  }
}
}
class _HomeHeader extends StatelessWidget {
  final String childName;
  final int points;

  const _HomeHeader({
    required this.childName,
    required this.points,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'أهلاً،',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '✦ $childName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFBE3EA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.girl,
                      color: Color(0xFFD1637F),
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                     Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'رصيدك من نقاط نور',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '$points نقطة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// One task card for the "مهام اليوم" list. Same shape is reused for
// completed, pending, and rejected tasks, just with different colors,
// icons, and status text passed in.
class _AssignmentCard extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  const _AssignmentCard({
    required this.assignment,
    this.onComplete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = assignment.status.toLowerCase();

    late final Color statusColor;
    late final Color borderColor;
    late final Color circleColor;
    late final IconData circleIcon;
    late final String statusText;

    switch (status) {
      case 'approved':
        statusColor = AppColors.success;
        borderColor = const Color(0xFFBFE3C6);
        circleColor = AppColors.success;
        circleIcon = Icons.check;
        statusText = 'معتمدة';
        break;

      case 'pending_review':
        statusColor = const Color(0xFFC08A3E);
        borderColor = const Color(0xFFF0DFA8);
        circleColor = AppColors.gold;
        circleIcon = Icons.access_time;
        statusText = 'بانتظار المراجعة';
        break;

      case 'rejected':
        statusColor = AppColors.error;
        borderColor = const Color(0xFFF0B8B8);
        circleColor = AppColors.error;
        circleIcon = Icons.close;
        statusText = 'مرفوضة';
        break;

      case 'pending':
      default:
        statusColor = AppColors.primary;
        borderColor = AppColors.primaryLight;
        circleColor = AppColors.primary;
        circleIcon = Icons.radio_button_unchecked;
        statusText = 'لم تُنجز بعد';
        break;
    }

    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: status == 'pending' ? onComplete : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                circleIcon,
                color: Colors.white,
                size: 18,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    assignment.task.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${assignment.task.points} نقاط ✦ $statusText',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
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
              _categoryIcon(assignment.task.category),
              color: AppColors.primaryDark,
              size: 20,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }

  IconData _categoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'religious':
        return Icons.mosque;

      case 'financial':
        return Icons.credit_card;

      case 'moral':
        return Icons.volunteer_activism;

      case 'social':
        return Icons.groups;

      default:
        return Icons.task_alt;
    }
  }
}

// Bottom navigation bar for the child screens. Simpler than the parent
// one: just 4 plain items in a row, no floating center button.
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(
        icon: Icons.home_rounded,
        label: 'الرئيسية',
      ),
      _NavItem(
        icon: Icons.favorite_border,
        label: 'أمنياتي',
      ),
      _NavItem(
        icon: Icons.card_giftcard_outlined,
        label: 'المكافآت',
      ),
      _NavItem(
        icon: Icons.bar_chart_rounded,
        label: 'تقدّمي',
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (index) {
              return GestureDetector(
                onTap: () => onTap(index),
                child: items[index].build(
                  isActive: currentIndex == index,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// One icon + label pair inside the bottom navigation bar.
class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });

  Widget build({
    required bool isActive,
  }) {
    final color = isActive
        ? AppColors.primary
        : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive
                ? FontWeight.bold
                : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}