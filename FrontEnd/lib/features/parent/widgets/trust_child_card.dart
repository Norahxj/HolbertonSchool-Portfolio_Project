import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
  
class TrustChildCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;


  const TrustChildCard({
    super.key,
    required this.value,
    required this.onChanged,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'هل تثق بجدية طفلك في هذه المهمة؟',
          textAlign: TextAlign.right,
        ),
        subtitle: const Text(
          'إذا وثقت، ستُعتمد المهمة تلقائيًا',
          textAlign: TextAlign.right,
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}