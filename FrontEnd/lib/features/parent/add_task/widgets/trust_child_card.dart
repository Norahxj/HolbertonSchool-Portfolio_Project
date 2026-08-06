import 'dart:ui';

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

  bool get isArabic => PlatformDispatcher.instance.locale.languageCode == 'ar';

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
        controlAffinity: ListTileControlAffinity.leading,
        title: Align(
          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            isArabic
                ? 'هل تثق بجدية طفلك في هذه المهمة؟'
                : 'Do you trust your child to complete this task seriously?',
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
        ),
        subtitle: Align(
          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            isArabic
                ? 'إذا وثقت، ستُعتمد المهمة تلقائيًا'
                : 'If you do, the task will be approved automatically',
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
