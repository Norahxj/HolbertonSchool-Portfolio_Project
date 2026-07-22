import 'package:flutter/material.dart';
import 'package:frontend/features/child/services/point_api_service.dart';
import 'package:frontend/features/parent/services/child_api_service.dart';
import 'package:frontend/features/parent/services/dashboard_api_service.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/child_dashboard_model.dart';
import '../../../models/child_model.dart';
import '../../../models/user_model.dart';
import '../../../services/task_api_service.dart';
import '../../../services/user_api_service.dart';
import '../../child/screens/child_profile_screen.dart';
import 'add_child_screen.dart';
import 'task_review_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final TaskApiService _taskApiService = TaskApiService();

  final PointApiService _pointApiService = PointApiService();

  late Future<UserModel> _userFuture;

  late Future<List<ChildModel>> _childrenFuture;

  late Future<List<ChildDashboardModel>> _dashboardFuture;

  late Future<int> _pendingReviewCountFuture;

  late Future<Map<String, int?>> _pointsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _userFuture = UserApiService().getCurrentUser();

    _childrenFuture = ChildApiService().getChildren();

    _dashboardFuture = DashboardApiService().getDashboard();

    _pendingReviewCountFuture = _getPendingReviewCount(_childrenFuture);

    _pointsFuture = _getChildrenPoints(_childrenFuture);
  }

  Future<int> _getPendingReviewCount(
  Future<List<ChildModel>> childrenFuture,
) async {
  final children = await childrenFuture;

  final assignmentLists = await Future.wait(
    children.map(
      (child) => _taskApiService.getAssignmentsForChild(
        child.id,
      ),
    ),
  );

  int count = 0;

  for (final assignments in assignmentLists) {
    count += assignments.where((assignment) {
      return assignment.needsParentApproval;
    }).length;
  }

  return count;
}

  Future<Map<String, int?>> _getChildrenPoints(
    Future<List<ChildModel>> childrenFuture,
  ) async {
    final children = await childrenFuture;

    final entries = await Future.wait(
      children.map((child) async {
        try {
          final points = await _pointApiService.getChildPoints(child.id);

          return MapEntry<String, int?>(child.id, points);
        } catch (error) {
          debugPrint(
            'Could not load points for '
            '${child.name}: $error',
          );

          return MapEntry<String, int?>(child.id, null);
        }
      }),
    );

    return Map<String, int?>.fromEntries(entries);
  }

  Future<void> _openAddChildScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddChildScreen()),
    );

    if (!mounted) return;

    if (result == true) {
      setState(_loadData);
    }
  }

  Future<void> _openTaskReviewScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskReviewScreen()),
    );

    if (!mounted) return;

    // Refresh the progress, points and review count.
    setState(_loadData);
  }

  ChildModel? _findChild(List<ChildModel> children, String childId) {
    for (final child in children) {
      if (child.id == childId) {
        return child;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: FutureBuilder<UserModel>(
              future: _userFuture,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError || !userSnapshot.hasData) {
                  return const Center(
                    child: Text('تعذر تحميل بيانات المستخدم'),
                  );
                }

                final user = userSnapshot.data!;

                return Column(
                  children: [
                    _WelcomeBanner(user: user),

                    const SizedBox(height: AppSpacing.lg),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('أطفالك', style: AppTextStyles.arabicTitle),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    FutureBuilder<List<ChildModel>>(
                      future: _childrenFuture,
                      builder: (context, childrenSnapshot) {
                        if (childrenSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (childrenSnapshot.hasError) {
                          return const Center(
                            child: Text('تعذر تحميل الأطفال'),
                          );
                        }

                        final children =
                            childrenSnapshot.data ?? <ChildModel>[];

                        if (children.isEmpty) {
                          return const Center(child: Text('لا يوجد أطفال بعد'));
                        }

                        return FutureBuilder<List<ChildDashboardModel>>(
                          future: _dashboardFuture,
                          builder: (context, dashboardSnapshot) {
                            if (dashboardSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (dashboardSnapshot.hasError) {
                              return const Center(
                                child: Text('تعذر تحميل تقدم الأطفال'),
                              );
                            }

                            final dashboards =
                                dashboardSnapshot.data ??
                                <ChildDashboardModel>[];

                            return FutureBuilder<Map<String, int?>>(
                              future: _pointsFuture,
                              builder: (context, pointsSnapshot) {
                                final pointsByChild =
                                    pointsSnapshot.data ?? <String, int?>{};

                                final pointsAreLoading =
                                    pointsSnapshot.connectionState ==
                                    ConnectionState.waiting;

                                return Column(
                                  children: dashboards.map((dashboard) {
                                    final child = _findChild(
                                      children,
                                      dashboard.childId,
                                    );

                                    if (child == null) {
                                      return const SizedBox.shrink();
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sm,
                                      ),
                                      child: _ChildProgressCard(
                                        child: child,
                                        dashboard: dashboard,
                                        points: pointsByChild[child.id],
                                        pointsAreLoading: pointsAreLoading,
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _AddChildButton(onTap: _openAddChildScreen),

                    const SizedBox(height: AppSpacing.md),

                    FutureBuilder<int>(
                      future: _pendingReviewCountFuture,
                      builder: (context, snapshot) {
                        return _TaskReviewButton(
                          count: snapshot.data ?? 0,
                          onTap: _openTaskReviewScreen,
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final UserModel user;

  const _WelcomeBanner({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFE4D9F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.home_rounded,
            color: AppColors.primaryDark,
            size: 48,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'مرحبًا ${user.firstName} '
            '${user.lastName}!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),

          const Text(
            'أنتِ تبنين جيلاً رائعًا',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ChildProgressCard extends StatelessWidget {
  final ChildModel child;
  final ChildDashboardModel dashboard;
  final int? points;
  final bool pointsAreLoading;

  const _ChildProgressCard({
    required this.child,
    required this.dashboard,
    required this.points,
    required this.pointsAreLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChildProfileScreen(child: child, dashboard: dashboard),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            // The old child avatar was replaced
            // with the child's current points.
            _ChildPointsBadge(points: points, isLoading: pointsAreLoading),

            Expanded(
              child: Column(
                children: [
                  Text(
                    dashboard.childName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '${dashboard.childAge} سنوات',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            _ProgressRing(percent: dashboard.progressPercentage.round()),
          ],
        ),
      ),
    );
  }
}

class _ChildPointsBadge extends StatelessWidget {
  final int? points;
  final bool isLoading;

  const _ChildPointsBadge({required this.points, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.goldLight,
        shape: BoxShape.circle,
      ),
      child: isLoading
          ? const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gold,
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.gold, size: 14),

                const SizedBox(height: 1),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    points?.toString() ?? '—',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const Text(
                  'نقطة',
                  style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
                ),
              ],
            ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int percent;

  const _ProgressRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    final safePercent = percent.clamp(0, 100);

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
              value: safePercent / 100,
              strokeWidth: 5,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),

          Text(
            '$safePercent%',
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

class _AddChildButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddChildButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Row(
        textDirection: TextDirection.ltr,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.add, color: Colors.white),
          ),

          Expanded(
            child: Center(
              child: Text(
                'إضافة طفل',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _TaskReviewButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _TaskReviewButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              const Icon(Icons.fact_check_outlined, color: AppColors.primary),

              const SizedBox(width: AppSpacing.md),

              const Expanded(
                child: Text(
                  'مراجعة المهام',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              if (count > 0)
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.error,
                  child: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              else
                const Icon(Icons.chevron_left, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
