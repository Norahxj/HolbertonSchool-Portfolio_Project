import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ProfileFieldLabel extends StatelessWidget {
  final String text;

  const ProfileFieldLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
