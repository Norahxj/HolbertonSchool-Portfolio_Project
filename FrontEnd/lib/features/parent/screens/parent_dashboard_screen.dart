import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import '../../child/screens/child_profile_screen.dart';
import 'add_child_screen.dart';
import 'task_review_screen.dart';
import '../../../models/child_model.dart';
import '../../../services/child_api_service.dart';
import '../../../services/user_api_service.dart';
import '../../../models/user_model.dart';
import '../../../models/child_dashboard_model.dart';
import '../../../services/dashboard_api_service.dart';

// Parent Home Dashboard screen (Screen 4).
//
// This first pass uses simple hardcoded placeholder data (parent name,
// one child, weekly progress). No backend calls are made here yet.
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
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
    

    if (result == true) {
  setState(() {
    _dashboardFuture = DashboardApiService().getDashboard();
    _childrenFuture = ChildApiService().getChildren();
  });
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
              builder: (context, snapshot) {
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Error loading user data'));
                }

                final UserModel user = snapshot.data!;

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

    final children = childrenSnapshot.data ?? [];

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
          return Center(
            child: Text(
              dashboardSnapshot.error.toString(),
            ),
          );
        }

        final dashboards = dashboardSnapshot.data ?? [];

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

                    _AddChildButton(onTap: _openAddChildScreen),

                    const SizedBox(height: AppSpacing.lg),

                    _TaskReviewPreviewCard(),

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
      child: const Icon(Icons.person, color: AppColors.primaryDark, size: 24),
    );
  }
}

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

class _WelcomeBanner extends StatelessWidget {
  final UserModel user;
  const _WelcomeBanner({required this.user});

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
        textDirection: TextDirection.rtl,
mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
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
    const SizedBox(width: AppSpacing.md),
    const Icon(
      Icons.home_rounded,
      size: 56,
      color: AppColors.primaryDark,
    ),
  ],
)
    );
  }
}

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
      // TODO: This navigation is temporary until real child/profile routing is finalized.
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
            _WeeklyProgressRing(
  percent: dashboard.progressPercentage.round(),
),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dashboard.childName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dashboard.childAge} سنوات',
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
              child: const Icon(Icons.girl, color: Color(0xFFD1637F), size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyProgressRing extends StatelessWidget {
  final int percent;

  const _WeeklyProgressRing({required this.percent});

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
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
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
                style: TextStyle(fontSize: 7, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddChildButton extends StatelessWidget {
  final void Function()? onTap;

  const _AddChildButton({required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'إضافة طفل',
                    style: const TextStyle(
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
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple preview card that reminds the parent that some tasks are
// waiting for review. Tapping it opens the full Task Review screen.
class _TaskReviewPreviewCard extends StatelessWidget {
  const _TaskReviewPreviewCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskReviewScreen()),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'مراجعة المهام',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'لديك ٢ مهمة بانتظار المراجعة',
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

// Draws a simple dashed rounded-rect border around its child, since Flutter
// has no built-in dashed border. This walks the border path in short
// segments, drawing a dash then skipping a gap, all the way around.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, this.radius = 16});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.5;
    const dashWidth = 6.0;
    const gapWidth = 4.0;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

