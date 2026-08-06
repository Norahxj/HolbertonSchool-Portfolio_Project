import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppNavigationItem {
  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AppNavigationItem({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class AppBottomNavigation extends StatelessWidget {
  final List<AppNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 9, 8, 8),
        decoration: BoxDecoration(
          color: AppColors.navBackground,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: items
              .map((item) {
                return Expanded(
                  child: _AppNavigationButton(
                    item: item,
                    isSelected: currentIndex == item.index,
                    onTap: () => onTap(item.index),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _AppNavigationButton extends StatelessWidget {
  final AppNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _AppNavigationButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primaryDark : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                scale: isSelected ? 1.12 : 1,
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: 23,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
