import 'package:flutter/material.dart';
import 'package:frontend/features/child/controllers/child_controller.dart';
import 'package:frontend/models/child_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import 'child_task_details_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  final controller = ChildController();
  Future<void> _reload() async {
    await controller.loadData();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
  final percent = controller.weeklyProgressPercent;
  final completed = controller.completedTasks;
  final total = controller.totalTasks;
  if (controller.isLoading) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (controller.child == null) {
    return const Scaffold(
      body: Center(
        child: Text('لا يوجد حساب طفل'),
      ),
    );
  }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _HomeHeader(child: controller.child!),
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
                        child: Text(
                          '$completed / $total',
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

                  if (controller.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (controller.assignments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'لا توجد مهام',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ...controller.assignments.map(
                      (assignment) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _TaskCard(
                          title: assignment.task.title,
                          points: assignment.task.points,
                          statusText: controller.statusText(assignment.status),
                          statusColor: controller.statusColor(assignment.status),
                          borderColor: controller.getBorderColor(assignment.status),
                          circleColor: controller.getCircleColor(assignment.status),
                          circleIcon: controller.statusIcon(assignment.status),
                          taskIcon: controller.taskIcon(assignment.task.category),
                          onTap: () async {
                            final updatedAssignment = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChildTaskDetailsScreen(
                                  assignment: assignment,
                                ),
                              ),
                            );

                            if (updatedAssignment != null) {
                              setState(() {
                                final index = controller.assignments.indexWhere(
                                  (e) => e.id == updatedAssignment.id,
                                );
                                if (index != -1) {
                                  controller.assignments[index] = updatedAssignment;
                                }
                              });
                            }
                          },
                        ),
                      ),
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

class _HomeHeader extends StatelessWidget {
  final ChildModel child;

  const _HomeHeader({required this.child});

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
                            '${child.points} نقاط ✦',
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}
