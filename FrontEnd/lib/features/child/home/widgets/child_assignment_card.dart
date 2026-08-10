import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../models/task_assignment_model.dart';

class ChildAssignmentCard extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final VoidCallback? onComplete;
  final VoidCallback onTap;
  final bool isUpdating;
  final bool isArabic;

  const ChildAssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
    required this.isUpdating,
    required this.isArabic,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final category = childHomeCategoryStyle(
      assignment.task.category,
      isArabic,
    );

    final status = _statusStyle(
      assignment.status,
      isArabic,
    );

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
              color: category.color.withValues(alpha: 0.28),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: category.color.withValues(alpha: 0.10),
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
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 25,
                ),
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
                      textAlign: isArabic
                          ? TextAlign.right
                          : TextAlign.left,
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
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return Material(
      color: canComplete
          ? AppColors.primary
          : status.background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: canComplete ? onTap : null,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            canComplete
                ? Icons.check_rounded
                : status.icon,
            color: canComplete
                ? Colors.white
                : status.color,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: foreground,
          ),

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

class ChildHomeCategoryStyle {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const ChildHomeCategoryStyle({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
}

ChildHomeCategoryStyle childHomeCategoryStyle(
  String? category,
  bool isArabic,
) {
  switch (category?.toLowerCase()) {
    case 'religious':
      return ChildHomeCategoryStyle(
        label: isArabic ? 'قيمة دينية' : 'Religious Value',
        icon: Icons.mosque_rounded,
        color: AppColors.primaryDark,
        background: AppColors.primaryLight,
      );

    case 'financial':
      return ChildHomeCategoryStyle(
        label: isArabic ? 'مهارة مالية' : 'Financial Skill',
        icon: Icons.monetization_on_rounded,
        color: const Color(0xFFB77700),
        background: AppColors.goldLight,
      );

    case 'moral':
      return ChildHomeCategoryStyle(
        label: isArabic ? 'قيمة أخلاقية' : 'Moral Value',
        icon: Icons.volunteer_activism_rounded,
        color: AppColors.pink,
        background: AppColors.pinkLight,
      );

    case 'social':
      return ChildHomeCategoryStyle(
        label: isArabic ? 'مهمة اجتماعية' : 'Social Task',
        icon: Icons.groups_rounded,
        color: AppColors.sky,
        background: AppColors.skyLight,
      );

    default:
      return ChildHomeCategoryStyle(
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

_StatusStyle _statusStyle(
  String status,
  bool isArabic,
) {
  switch (status.toLowerCase()) {
    case 'approved':
      return _StatusStyle(
        label: isArabic
            ? 'تم الاعتماد'
            : 'Approved',
        icon: Icons.verified_rounded,
        color: AppColors.mint,
        background: AppColors.mintLight,
      );

    case 'completed':
    case 'pending_review':
      return _StatusStyle(
        label: isArabic
            ? 'بانتظار المراجعة'
            : 'Waiting for Review',
        icon: Icons.hourglass_top_rounded,
        color: AppColors.orange,
        background: AppColors.orangeLight,
      );

    case 'rejected':
      return _StatusStyle(
        label: isArabic
            ? 'حاول مرة أخرى'
            : 'Try Again',
        icon: Icons.refresh_rounded,
        color: AppColors.coral,
        background: AppColors.coralLight,
      );

    case 'pending':
    default:
      return _StatusStyle(
        label: isArabic
            ? 'جاهزة للإنجاز'
            : 'Ready',
        icon: Icons.play_arrow_rounded,
        color: AppColors.sky,
        background: AppColors.skyLight,
      );
  }
}