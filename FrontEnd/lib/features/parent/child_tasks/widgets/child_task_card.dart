import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/task_assignment_model.dart';

class ChildTaskCard extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final bool canDelete;
  final bool isDeleting;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  const ChildTaskCard({
    super.key,
    required this.assignment,
    required this.canDelete,
    required this.isDeleting,
    required this.onTap,
    required this.onDelete,
  });

  String _statusLabel(BuildContext context) {
    final l10n = context.l10n;

    if (assignment.needsParentApproval) {
      return l10n.awaitingReview;
    }

    if (assignment.isApproved) {
      return l10n.completed;
    }

    if (assignment.isRejected) {
      return l10n.rejected;
    }

    if (assignment.isPending) {
      return l10n.active;
    }

    return l10n.completed;
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
        onTap: isDeleting ? null : onTap,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusLabel(context),
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
                  onPressed: isDeleting
                      ? null
                      : () {
                          onDelete();
                        },
                  tooltip: context.l10n.deleteTask,
                  icon: isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.error,
                          ),
                        )
                      : const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 21,
                        ),
                ),
              _PointsBadge(points: assignment.task.points),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  final int points;

  const _PointsBadge({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 13, color: AppColors.gold),
          const SizedBox(width: 4),
          Text(
            '$points',
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
