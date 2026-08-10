import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppFieldLabel extends StatelessWidget {
  final String text;

  const AppFieldLabel({
    super.key,
    required this.text,
  });

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