import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';

// Task Review screen (Screen 13).
//
// This first pass is static/placeholder only: the pending tasks below are
// hardcoded, and the approve/reject buttons don't do anything real yet
// (see the TODO comments). No backend calls happen here.
class TaskReviewScreen extends StatelessWidget {
  const TaskReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'مراجعة المهام',
                          style: AppTextStyles.arabicTitle,
                        ),
                      ),
                    ),
                    _RoundBackButton(onTap: () => Navigator.pop(context)),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'راجع ما أنجزه أطفالك واعتمده',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDA15E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '٢ مهمة',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'بانتظار المراجعة',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                _PendingTaskCard(
                  childName: 'سارة',
                  taskTitle: 'الصلاة في وقتها',
                  points: 10,
                  timeText: 'أنجزتها اليوم 3:25',
                  avatarColor: const Color(0xFFFBE3EA),
                  iconColor: const Color(0xFFD1637F),
                ),

                const SizedBox(height: AppSpacing.md),

                _PendingTaskCard(
                  childName: 'سلمان',
                  taskTitle: 'قراءة القرآن',
                  points: 15,
                  timeText: 'أنجزها اليوم 4:30 م',
                  avatarColor: const Color(0xFFDCEBFB),
                  iconColor: const Color(0xFF4A90D9),
                ),

                const SizedBox(height: AppSpacing.xl),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'عند الاعتماد تُضاف نقاط نور إلى رصيد الطفل',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.auto_awesome, color: AppColors.gold, size: 14),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Round back button in the top-right corner, same style as other screens.
class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

// One pending task waiting for the parent's approval or rejection.
class _PendingTaskCard extends StatelessWidget {
  final String childName;
  final String taskTitle;
  final int points;
  final String timeText;
  final Color avatarColor;
  final Color iconColor;

  const _PendingTaskCard({
    required this.childName,
    required this.taskTitle,
    required this.points,
    required this.timeText,
    required this.avatarColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$points',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 14,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$childName . $taskTitle',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeText,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
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
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: iconColor, size: 20),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Approve this task once backend integration is
                    // ready.
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'اعتماد',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.check, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Reject this task once backend integration is
                    // ready.
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9DEDE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'رفض',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.close, color: AppColors.error, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
