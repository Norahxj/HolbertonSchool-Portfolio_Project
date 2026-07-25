import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_bottom_navigation.dart';
import '../../../core/navigation/app_navigation_controller.dart';
import '../screens/child_home_screen.dart';
import '../screens/child_progress_screen.dart';
import '../screens/child_rewards_screen.dart';
import '../screens/child_wishlist_screen.dart';

class ChildNav extends StatelessWidget {
  final bool isArabic;

  const ChildNav({super.key, this.isArabic = true});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppNavigationController(initialIndex: 0),
      child: _ChildNavigationView(isArabic: isArabic),
    );
  }
}

class _ChildNavigationView extends StatelessWidget {
  final bool isArabic;

  const _ChildNavigationView({required this.isArabic});

  static const List<AppNavigationItem> _navigationItems = [
    AppNavigationItem(
      index: 0,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      arabicLabel: 'الرئيسية',
      englishLabel: 'Home',
    ),
    AppNavigationItem(
      index: 1,
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
      arabicLabel: 'أمنياتي',
      englishLabel: 'Wishes',
    ),
    AppNavigationItem(
      index: 2,
      icon: Icons.card_giftcard_outlined,
      selectedIcon: Icons.card_giftcard_rounded,
      arabicLabel: 'المكافآت',
      englishLabel: 'Rewards',
    ),
    AppNavigationItem(
      index: 3,
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
      arabicLabel: 'تقدّمي',
      englishLabel: 'Progress',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<AppNavigationController>();

    final pages = <Widget>[
      navigation.isLoaded(0)
          ? const ChildHomeScreen()
          : const SizedBox.shrink(),

      navigation.isLoaded(1)
          ? const ChildWishlistScreen()
          : const SizedBox.shrink(),

      navigation.isLoaded(2)
          ? const ChildRewardsScreen()
          : const SizedBox.shrink(),

      navigation.isLoaded(3)
          ? const ChildProgressScreen()
          : const SizedBox.shrink(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: navigation.currentIndex, children: pages),
      bottomNavigationBar: AppBottomNavigation(
        items: _navigationItems,
        currentIndex: navigation.currentIndex,
        isArabic: isArabic,
        onTap: navigation.selectTab,
      ),
    );
  }
}
