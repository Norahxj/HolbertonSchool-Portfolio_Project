import 'package:flutter/material.dart';
import 'package:frontend/models/child_model.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/storage/secure_storage.dart';
import 'child_task_details_screen.dart';

// Child Home Dashboard screen (Screen 21).
//
// The child's information is loaded from secure storage.
// The task information is currently static placeholder data.
class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  ChildModel? child;

  @override
  void initState() {
    super.initState();
    _loadChild();
  }

  Future<void> _loadChild() async {
    final data = await SecureStorage.getChild();

    if (!mounted) return;

    setState(() {
      child = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _HomeHeader(child: child!),

          Expanded(
            child: SingleChildScrollView(
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
                        child: const Text(
                          '3/5',
                          style: TextStyle(
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

                  const _TaskCard(
                    title: 'الصلاة في وقتها',
                    points: 10,
                    statusText: 'معتمدة تلقائيًا',
                    statusColor: AppColors.success,
                    borderColor: Color(0xFFBFE3C6),
                    circleColor: AppColors.success,
                    circleIcon: Icons.check,
                    taskIcon: Icons.mosque,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _TaskCard(
                    title: 'ترتيب السرير',
                    points: 5,
                    statusText: 'بانتظار المراجعة',
                    statusColor: const Color(0xFFC08A3E),
                    borderColor: const Color(0xFFF0DFA8),
                    circleColor: AppColors.gold,
                    circleIcon: Icons.access_time,
                    taskIcon: Icons.king_bed_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChildTaskDetailsScreen(
                            title: 'ترتيب السرير',
                            points: 5,
                            description:
                                'رتّب سريرك في الصباح قبل الذهاب للمدرسة.',
                            frequencyLabel: 'يوميًا',
                            icon: Icons.king_bed_outlined,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  const _TaskCard(
                    title: 'توفير مصروفي',
                    points: 10,
                    statusText: 'مرفوضة',
                    statusColor: AppColors.error,
                    borderColor: Color(0xFFF0B8B8),
                    circleColor: AppColors.error,
                    circleIcon: Icons.close,
                    taskIcon: Icons.credit_card,
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

// Purple gradient header containing the greeting, avatar,
// and the child's Noor Points balance.
class _HomeHeader extends StatelessWidget {
  final ChildModel child;

  const _HomeHeader({
    required this.child,
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
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          '✦ ${child.name}',
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
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: const Row(
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
                            '240 نقطة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
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

// One task card used for completed, pending, and rejected tasks.
class _TaskCard extends StatelessWidget {
  final String title;
  final int points;
  final String statusText;
  final Color statusColor;
  final Color borderColor;
  final Color circleColor;
  final IconData circleIcon;
  final IconData taskIcon;
  final VoidCallback? onTap;

  const _TaskCard({
    required this.title,
    required this.points,
    required this.statusText,
    required this.statusColor,
    required this.borderColor,
    required this.circleColor,
    required this.circleIcon,
    required this.taskIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          Container(
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
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '$points نقاط ✦ $statusText',
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
              taskIcon,
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
}
