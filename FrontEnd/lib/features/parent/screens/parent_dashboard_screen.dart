import 'package:flutter/material.dart';
import 'package:frontend/features/parent/services/child_api_service.dart';
import 'package:frontend/features/parent/services/dashboard_api_service.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/child_dashboard_model.dart';
import '../../../models/child_model.dart';
import '../../../models/user_model.dart';
import '../../../services/user_api_service.dart';
import '../../child/screens/child_profile_screen.dart';
import 'add_child_screen.dart';

// Parent Home Dashboard screen (Screen 4).
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({
    super.key,
  });

  @override
  State<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  late Future<UserModel> _userFuture;
  late Future<List<ChildDashboardModel>> _dashboardFuture;
  late Future<List<ChildModel>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _userFuture = UserApiService().getCurrentUser();
    _dashboardFuture = DashboardApiService().getDashboard();
    _childrenFuture = ChildApiService().getChildren();
  }

  Future<void> _openAddChildScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddChildScreen(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _dashboardFuture = DashboardApiService().getDashboard();
        _childrenFuture = ChildApiService().getChildren();
      });
    }
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
                if (userSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (userSnapshot.hasError || !userSnapshot.hasData) {
                  return const Center(
                    child: Text('تعذر تحميل بيانات المستخدم'),
                  );
                }

                final user = userSnapshot.data!;

                return Column(
                  children: [
                    // The duplicated black parent name was removed.
                    // The parent name now appears only inside this banner.
                    _WelcomeBanner(
                      user: user,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'أطفالك',
                        style: AppTextStyles.arabicTitle,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    FutureBuilder<List<ChildModel>>(
                      future: _childrenFuture,
                      builder: (context, childrenSnapshot) {
                        if (childrenSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
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
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              'لا يوجد أطفال بعد',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }

                        return FutureBuilder<List<ChildDashboardModel>>(
                          future: _dashboardFuture,
                          builder: (context, dashboardSnapshot) {
                            if (dashboardSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (dashboardSnapshot.hasError) {
                              return Center(
                                child: Text(
                                  dashboardSnapshot.error.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            final dashboards =
                                dashboardSnapshot.data ??
                                <ChildDashboardModel>[];

                            if (dashboards.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: Text(
                                  'لا توجد بيانات تقدّم بعد',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: dashboards.map((dashboard) {
                                final child = children.firstWhere(
                                  (item) => item.id == dashboard.childId,
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  child: _ChildProgressCard(
                                    child: child,
                                    dashboard: dashboard,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _AddChildButton(
                      onTap: _openAddChildScreen,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // TODO: Add the "مراجعة المهام" section later
                    // when the task-review feature is ready.
                    //
                    // const _TaskReviewPreviewCard(),

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

// Welcome banner containing the parent's name.
class _WelcomeBanner extends StatelessWidget {
  final UserModel user;

  const _WelcomeBanner({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE4D9F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.home_rounded,
            size: 48,
            color: AppColors.primaryDark,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'مرحبًا ${user.firstName} ${user.lastName}!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'أنتِ تبنين جيلاً رائعًا',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Card showing one child's information and weekly progress.
class _ChildProgressCard extends StatelessWidget {
  final ChildModel child;
  final ChildDashboardModel dashboard;

  const _ChildProgressCard({
    required this.child,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChildProfileScreen(
              child: child,
              dashboard: dashboard,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
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
        child: Row(
          children: [
            _ChildAvatar(
              avatarIndex: child.avatarIndex,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dashboard.childName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '${dashboard.childAge} سنوات',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _WeeklyProgressRing(
              percent: dashboard.progressPercentage.round(),
            ),
          ],
        ),
      ),
    );
  }
}

// Displays the avatar selected when the child was added.
class _ChildAvatar extends StatelessWidget {
  final int avatarIndex;

  const _ChildAvatar({
    required this.avatarIndex,
  });

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
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 28,
      ),
    );
  }
}

// Circular weekly progress indicator.
class _WeeklyProgressRing extends StatelessWidget {
  final int percent;

  const _WeeklyProgressRing({
    required this.percent,
  });

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
              valueColor: const AlwaysStoppedAnimation(
                AppColors.primary,
              ),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$safePercent%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const Text(
                'أسبوعي',
                style: TextStyle(
                  fontSize: 7,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Button that opens the Add Child screen.
class _AddChildButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddChildButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.primary.withOpacity(0.4),
          radius: 20,
        ),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 22,
                ),
              ),

              const Expanded(
                child: Center(
                  child: Text(
                    'إضافة طفل',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),

              // Empty space keeps the text visually centered.
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }
}

// Draws the dashed border around the Add Child button.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    this.radius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.5;
    const dashWidth = 6.0;
    const gapWidth = 4.0;

    final roundedRectangle = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(roundedRectangle);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(
          0.0,
          metric.length,
        );

        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );

        distance += dashWidth + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _DashedBorderPainter oldDelegate,
  ) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius;
  }
}