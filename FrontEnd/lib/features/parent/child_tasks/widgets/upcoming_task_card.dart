import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../models/upcoming_child_task.dart';

class UpcomingTaskCard extends StatelessWidget {
  final UpcomingChildTask item;
  final bool canDelete;
  final bool isDeleting;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  const UpcomingTaskCard({
    super.key,
    required this.item,
    required this.canDelete,
    required this.isDeleting,
    required this.onTap,
    required this.onDelete,
  });

  String _frequencyLabel(BuildContext context) {
    final frequency = item.task.taskFrequency.trim().toUpperCase();

    if (frequency == 'WEEKLY') {
      return context.l10n.weekly;
    }

    return context.l10n.monthly;
  }

  String _formattedDate(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return DateFormat('EEEE، d MMMM y', locale).format(item.nextDate);
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
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.32),
            ),
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
                  Icons.event_available_outlined,
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
                      item.task.title,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            context.l10n.upcoming,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        Text(
                          _frequencyLabel(context),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.nextTaskDate(_formattedDate(context)),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (canDelete) ...[
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
                const SizedBox(width: 2),
              ],
              _UpcomingPointsBadge(points: item.task.points),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingPointsBadge extends StatelessWidget {
  final int points;

  const _UpcomingPointsBadge({required this.points});

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
            textDirection: ui.TextDirection.ltr,
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
