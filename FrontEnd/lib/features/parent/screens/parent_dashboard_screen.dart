import 'package:flutter/material.dart';
import 'package:frontend/features/parent/screens/add_child_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/child_model.dart';
import '../../../models/user_model.dart';
import '../../child/screens/child_profile_screen.dart';
import 'task_review_screen.dart';

// Parent Home Dashboard screen (Screen 4).
//
// The user and children requests are created inside ParentNav and passed
// into this screen. This prevents the requests from restarting whenever
// the parent switches between navigation tabs.
class ParentDashboardScreen extends StatelessWidget {
  final Future<UserModel> userFuture;
  final Future<List<ChildModel>> childrenFuture;
  final VoidCallback onRefreshChildren;

  const ParentDashboardScreen({
    super.key,
    required this.userFuture,
    required this.childrenFuture,
    required this.onRefreshChildren,
  });

  Future<void> _openAddChildScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddChildScreen(),
      ),
    );

    if (!context.mounted) return;

    // Refresh the children list only when a child was successfully added.
    if (result == true) {
      onRefreshChildren();
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
              future: userFuture,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (userSnapshot.hasError || !userSnapshot.hasData) {
                  return const Center(
                    child: Text('Error loading user data'),
                  );
                }

                final user = userSnapshot.data!;

                return Column(
                  children: [
                    Row(
                      children: [
                        const _NotificationBell(),

                        Expanded(
                          child: Center(
                            child: Text(
                              'منزل ${user.firstName} ${user.lastName}',
                              style: AppTextStyles.arabicTitle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const _ProfileAvatar(),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _WelcomeBanner(user: user),

                    const SizedBox(height: AppSpacing.md),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'أطفالك',
                        style: AppTextStyles.arabicTitle,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    FutureBuilder<List<ChildModel>>(
                      future: childrenFuture,
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
                          return Center(
                            child: Text(
                              childrenSnapshot.error.toString(),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        final children =
                            childrenSnapshot.data ?? <ChildModel>[];

                        if (children.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              'لا يوجد أطفال بعد',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return Column(
                          children: children
                              .map(
                                (child) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  child: _ChildProgressCard(
                                    child: child,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _AddChildButton(
                      onTap: () {
                        _openAddChildScreen(context);
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    const _TaskReviewPreviewCard(),

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

// Parent profile icon shown in the dashboard header.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: AppColors.primaryDark,
        size: 24,
      ),
    );
  }
}

// Notification icon shown in the dashboard header.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_none,
            color: AppColors.primaryDark,
            size: 22,
          ),
          Positioned(
            top: 10,
            right: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Welcome message containing the signed-in parent's name.
class _WelcomeBanner extends StatelessWidget {
  final UserModel user;

  const _WelcomeBanner({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE4D9F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.home_rounded,
            size: 56,
            color: AppColors.primaryDark,
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'مرحبًا ${user.firstName} ${user.lastName}! ♥',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'أنتِ تبنين جيلاً رائعًا',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
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

// Card showing one child and their weekly progress.
class _ChildProgressCard extends StatelessWidget {
  final ChildModel child;

  const _ChildProgressCard({
    required this.child,
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
            _WeeklyProgressRing(
              percent: child.weeklyProgress,
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
                      child.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '${child.age} سنوات',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFBE3EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.girl,
                color: Color(0xFFD1637F),
                size: 22,
              ),
            ),
          ],
        ),
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

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
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

// Dashed Add Child button.
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
            ],
          ),
        ),
      ),
    );
  }
}

// Preview card that opens the Task Review screen.
class _TaskReviewPreviewCard extends StatelessWidget {
  const _TaskReviewPreviewCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TaskReviewScreen(),
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
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                color: AppColors.primaryDark,
                size: 22,
              ),
            ),

            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'مراجعة المهام',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'لديك ٢ مهمة بانتظار المراجعة',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '٢',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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

    final path = Path()
      ..addRRect(roundedRectangle);

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