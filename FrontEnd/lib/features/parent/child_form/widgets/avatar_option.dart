import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AvatarOption extends StatelessWidget {
  final String imagePath;
  final Color backgroundColor;
  final bool isSelected;
  final VoidCallback onTap;

  const AvatarOption({
    super.key,
    required this.imagePath,
    required this.backgroundColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 32,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
