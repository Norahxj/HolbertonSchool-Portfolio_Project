import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/child_task_details_controller.dart';

class ChildTaskDetailsView extends StatelessWidget {
  final IconData icon;
  final VoidCallback onBack;
  final Future<void> Function() onComplete;

  const ChildTaskDetailsView({
    super.key,
    required this.icon,
    required this.onBack,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChildTaskDetailsController>();
    final task = controller.assignment.task;

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final statusStyle = _statusStyle(controller);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppBackButton(
                    isArabic: isRtl,
                    onTap: onBack,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primaryDark,
                      size: 56,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  task.title,
                  style: AppTextStyles.arabicTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.noorPointsCount(task.points),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC08A3E),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusStyle.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusStyle.icon,
                          color: statusStyle.foregroundColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _statusText(context, controller),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusStyle.foregroundColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                _TaskDescriptionCard(
                  description: task.description,
                  frequency: _frequencyText(
                    context,
                    task.taskFrequency,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                _VerificationCard(
                  message: task.isAutoVerified
                      ? context.l10n.childTaskAutoVerificationMessage
                      : context.l10n.childTaskGuardianVerificationMessage,
                ),

                const SizedBox(height: AppSpacing.xl),

                _CompleteTaskButton(
                  controller: controller,
                  statusStyle: statusStyle,
                  text: _buttonText(context, controller),
                  icon: _buttonIcon(controller),
                  onComplete: onComplete,
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _frequencyText(
    BuildContext context,
    String frequency,
  ) {
    switch (frequency.toUpperCase()) {
      case 'DAILY':
        return context.l10n.daily;

      case 'WEEKLY':
        return context.l10n.weekly;

      case 'MONTHLY':
        return context.l10n.monthly;

      case 'ONCE':
        return context.l10n.once;

      default:
        if (frequency.trim().isEmpty) {
          return context.l10n.notSpecified;
        }

        return frequency;
    }
  }

  String _statusText(
    BuildContext context,
    ChildTaskDetailsController controller,
  ) {
    if (controller.isApproved) {
      return context.l10n.childTaskCompletedApproved;
    }

    if (controller.isPendingReview) {
      return context.l10n.childTaskWaitingGuardianReview;
    }

    if (controller.isRejected) {
      return context.l10n.rejected;
    }

    return context.l10n.childTaskReadyToComplete;
  }

  String _buttonText(
    BuildContext context,
    ChildTaskDetailsController controller,
  ) {
    if (controller.isApproved) {
      return context.l10n.childTaskApproved;
    }

    if (controller.isPendingReview) {
      return context.l10n.waitingForReview;
    }

    if (controller.isRejected) {
      return context.l10n.tryAgain;
    }

    return context.l10n.childTaskCompleteButton;
  }

  IconData _buttonIcon(
    ChildTaskDetailsController controller,
  ) {
    if (controller.isApproved) {
      return Icons.check_circle_rounded;
    }

    if (controller.isPendingReview) {
      return Icons.hourglass_top_rounded;
    }

    if (controller.isRejected) {
      return Icons.refresh_rounded;
    }

    return Icons.check_rounded;
  }

  _TaskStatusStyle _statusStyle(
    ChildTaskDetailsController controller,
  ) {
    if (controller.isApproved) {
      return const _TaskStatusStyle(
        foregroundColor: AppColors.success,
        backgroundColor: Color(0xFFE8F5EA),
        icon: Icons.check_circle_rounded,
      );
    }

    if (controller.isPendingReview) {
      return const _TaskStatusStyle(
        foregroundColor: Color(0xFFC08A3E),
        backgroundColor: Color(0xFFFFF4D6),
        icon: Icons.hourglass_top_rounded,
      );
    }

    if (controller.isRejected) {
      return const _TaskStatusStyle(
        foregroundColor: AppColors.error,
        backgroundColor: Color(0xFFF9DEDE),
        icon: Icons.cancel_rounded,
      );
    }

    return const _TaskStatusStyle(
      foregroundColor: AppColors.primary,
      backgroundColor: AppColors.primaryLight,
      icon: Icons.task_alt_rounded,
    );
  }
}

class _TaskDescriptionCard extends StatelessWidget {
  final String description;
  final String frequency;

  const _TaskDescriptionCard({
    required this.description,
    required this.frequency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.description,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            description.trim().isEmpty
                ? context.l10n.childTaskNoDescription
                : description,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),

              const SizedBox(width: 6),

              Text(
                frequency,
                style: const TextStyle(
                  fontSize: 13,
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

class _VerificationCard extends StatelessWidget {
  final String message;

  const _VerificationCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppColors.primary,
            size: 18,
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteTaskButton extends StatelessWidget {
  final ChildTaskDetailsController controller;
  final _TaskStatusStyle statusStyle;
  final String text;
  final IconData icon;
  final Future<void> Function() onComplete;

  const _CompleteTaskButton({
    required this.controller,
    required this.statusStyle,
    required this.text,
    required this.icon,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final canPress =
        controller.canComplete && !controller.isSubmitting;

    return GestureDetector(
      onTap: canPress ? onComplete : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: controller.canComplete
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.primaryGradient,
                )
              : null,
          color: controller.canComplete
              ? null
              : statusStyle.backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: controller.isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: controller.canComplete
                            ? Colors.white
                            : statusStyle.foregroundColor,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    Icon(
                      icon,
                      color: controller.canComplete
                          ? Colors.white
                          : statusStyle.foregroundColor,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _TaskStatusStyle {
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData icon;

  const _TaskStatusStyle({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.icon,
  });
}