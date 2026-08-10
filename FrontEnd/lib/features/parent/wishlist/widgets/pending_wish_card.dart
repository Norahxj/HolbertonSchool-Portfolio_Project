import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import 'wish_header.dart';
import 'wish_status_tag.dart';
import 'wish_stepper_button.dart';

class PendingWishCard extends StatefulWidget {
  final String childName;
  final int avatarIndex;
  final String wishTitle;
  final int startingPoints;
  final bool isProcessing;
  final Future<void> Function(int targetPoints) onApprove;
  final Future<void> Function() onReject;

  const PendingWishCard({
    super.key,
    required this.childName,
    required this.avatarIndex,
    required this.wishTitle,
    required this.startingPoints,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<PendingWishCard> createState() {
    return _PendingWishCardState();
  }
}

class _PendingWishCardState extends State<PendingWishCard> {
  static const int _pointsStep = 10;
  static const int _minimumPoints = 10;

  late int _requiredPoints;

  @override
  void initState() {
    super.initState();

    _requiredPoints = _normalizePoints(widget.startingPoints);
  }

  @override
  void didUpdateWidget(covariant PendingWishCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.startingPoints != widget.startingPoints) {
      _requiredPoints = _normalizePoints(widget.startingPoints);
    }
  }

  int _normalizePoints(int points) {
    if (points < _minimumPoints) {
      return _minimumPoints;
    }

    return points;
  }

  void _increasePoints() {
    if (widget.isProcessing) {
      return;
    }

    setState(() {
      _requiredPoints += _pointsStep;
    });
  }

  void _decreasePoints() {
    if (widget.isProcessing || _requiredPoints <= _minimumPoints) {
      return;
    }

    setState(() {
      _requiredPoints -= _pointsStep;
    });
  }

  Future<void> _approve() async {
    if (widget.isProcessing) {
      return;
    }

    await widget.onApprove(_requiredPoints);
  }

  Future<void> _reject() async {
    if (widget.isProcessing) {
      return;
    }

    await widget.onReject();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WishHeader(
            childName: widget.childName,
            wishTitle: widget.wishTitle,
            avatarIndex: widget.avatarIndex,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              WishStatusTag(
                label: l10n.pendingApproval,
                backgroundColor: AppColors.primaryLight,
                textColor: AppColors.primaryDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.pendingWishSubtitle,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PointsSelector(
            points: _requiredPoints,
            isProcessing: widget.isProcessing,
            onIncrease: _increasePoints,
            onDecrease: _decreasePoints,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.convertWishExplanation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _WishActions(
            isProcessing: widget.isProcessing,
            onApprove: _approve,
            onReject: _reject,
          ),
        ],
      ),
    );
  }
}

class _PointsSelector extends StatelessWidget {
  final int points;
  final bool isProcessing;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _PointsSelector({
    required this.points,
    required this.isProcessing,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          WishStepperButton(
            icon: Icons.add,
            isFilled: true,
            onTap: isProcessing ? null : onIncrease,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$points',
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
          const SizedBox(width: AppSpacing.sm),
          WishStepperButton(
            icon: Icons.remove,
            isFilled: false,
            onTap:
                isProcessing || points <= _PendingWishCardState._minimumPoints
                ? null
                : onDecrease,
          ),
          const Spacer(),
          Text(
            context.l10n.pointsGoal,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WishActions extends StatelessWidget {
  final bool isProcessing;
  final Future<void> Function() onApprove;
  final Future<void> Function() onReject;

  const _WishActions({
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _WishActionButton(
            label: context.l10n.convertToGoal,
            icon: Icons.check,
            isPrimary: true,
            isLoading: isProcessing,
            onPressed: isProcessing ? null : onApprove,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _WishActionButton(
            label: context.l10n.reject,
            icon: Icons.close,
            isPrimary: false,
            isLoading: false,
            onPressed: isProcessing ? null : onReject,
          ),
        ),
      ],
    );
  }
}

class _WishActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isLoading;
  final Future<void> Function()? onPressed;

  const _WishActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isPrimary ? Colors.white : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed == null
            ? null
            : () {
                onPressed!();
              },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: onPressed == null ? 0.65 : 1,
          child: Container(
            height: 56,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: isPrimary ? null : Border.all(color: AppColors.border),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foregroundColor,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: foregroundColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(icon, color: foregroundColor, size: 16),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
