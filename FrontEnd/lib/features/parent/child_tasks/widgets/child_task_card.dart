import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../models/task_assignment_model.dart';
import '../../../child/screens/child_task_details_screen.dart';

class ChildTaskCard extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final bool isArabic;
  final bool canDelete;
  final Future<void> Function() onDelete;

  const ChildTaskCard({
    super.key,
    required this.assignment,
    required this.isArabic,
    required this.canDelete,
    required this.onDelete,
  });

  String get _statusLabel {
    if (assignment.needsParentApproval) {
      return isArabic ? 'بانتظار المراجعة' : 'Awaiting review';
    }

    if (assignment.isApproved) {
      return isArabic ? 'مكتملة' : 'Completed';
    }

    if (assignment.isRejected) {
      return isArabic ? 'مرفوضة' : 'Rejected';
    }

    if (assignment.isPending) {
      return isArabic ? 'نشطة' : 'Active';
    }

    return isArabic ? 'مكتملة' : 'Completed';
  }

  Color get _statusColor {
    if (assignment.needsParentApproval) {
      return const Color(0xFFB7791F);
    }

    if (assignment.isApproved) {
      return AppColors.success;
    }

    if (assignment.isRejected) {
      return AppColors.error;
    }

    return AppColors.primaryDark;
  }

  Color get _statusBackground {
    if (assignment.needsParentApproval) {
      return const Color(0xFFFFF1D6);
    }

    if (assignment.isApproved) {
      return const Color(0xFFE4F4E8);
    }

    if (assignment.isRejected) {
      return const Color(0xFFF9DEDE);
    }

    return AppColors.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChildTaskDetailsScreen(
                assignment: assignment,
                icon: Icons.task_alt_outlined,
                isArabic: isArabic,
                parentView: true,
              ),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.task_alt_outlined,
                  color: AppColors.primaryDark,
                  size: 21,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.task.title,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              if (canDelete)
                IconButton(
                  onPressed: () async {
                    await onDelete();
                  },
                  tooltip: isArabic ? 'حذف المهمة' : 'Delete task',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 21,
                  ),
                ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 13,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${assignment.task.points}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
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
