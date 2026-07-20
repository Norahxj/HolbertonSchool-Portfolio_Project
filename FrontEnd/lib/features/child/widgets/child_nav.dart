import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../screens/child_home_screen.dart';
import '../screens/child_progress_screen.dart';
import '../screens/child_rewards_screen.dart';
import '../screens/child_wishlist_screen.dart';

// The single shared navigation container for all four child tabs.
class ChildNav extends StatefulWidget {
  const ChildNav({super.key});

  @override
  State<ChildNav> createState() => _ChildNavState();
}

class _ChildNavState extends State<ChildNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ChildHomeScreen(),
    ChildWishlistScreen(),
    ChildRewardsScreen(),
    ChildProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _ChildBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _ChildBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ChildBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _ChildNavDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'الرئيسية',
      ),
      _ChildNavDestination(
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
        label: 'أمنياتي',
      ),
      _ChildNavDestination(
        icon: Icons.card_giftcard_outlined,
        selectedIcon: Icons.card_giftcard_rounded,
        label: 'المكافآت',
      ),
      _ChildNavDestination(
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart_rounded,
        label: 'تقدّمي',
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 9, 8, 8),
        decoration: BoxDecoration(
          color: AppColors.navBackground,
          border: const Border(
            top: BorderSide(color: AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: List.generate(items.length, (index) {
            final item = items[index];

            return Expanded(
              child: _ChildNavItem(
                destination: item,
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ChildNavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _ChildNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _ChildNavItem extends StatelessWidget {
  final _ChildNavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildNavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? AppColors.primaryDark : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
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
                scale: isSelected ? 1.12 : 1,
                child: Icon(
                  isSelected
                      ? destination.selectedIcon
                      : destination.icon,
                  size: 23,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                destination.label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
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