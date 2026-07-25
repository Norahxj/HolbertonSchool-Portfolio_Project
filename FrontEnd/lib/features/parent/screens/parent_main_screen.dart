import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_bottom_navigation.dart';
import '../../../core/navigation/app_navigation_controller.dart';
import 'add_task_screen.dart';
import 'more_settings_screen.dart';
import 'parent_dashboard_screen.dart';
import 'reward_management_screen.dart';
import 'wishlist_approval_screen.dart';

class ParentMainScreen extends StatelessWidget {
  final int initialIndex;
  final bool isArabic;
  final VoidCallback? onLanguageToggle;

  const ParentMainScreen({
    super.key,
    this.initialIndex = 2,
    this.isArabic = true,
    this.onLanguageToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppNavigationController(initialIndex: initialIndex),
      child: _ParentNavigationView(
        isArabic: isArabic,
        onLanguageToggle: onLanguageToggle,
      ),
    );
  }
}

class _ParentNavigationView extends StatelessWidget {
  final bool isArabic;
  final VoidCallback? onLanguageToggle;

  const _ParentNavigationView({
    required this.isArabic,
    required this.onLanguageToggle,
  });

  static const List<AppNavigationItem> _navigationItems = [
    // The logical order is:
    // Tasks, Wishes, Home, Rewards, More.
    //
    // In Arabic, the first item appears on the right.
    // In English, the first item appears on the left.
    AppNavigationItem(
      index: 0,
      icon: Icons.list_alt_outlined,
      selectedIcon: Icons.list_alt,
      arabicLabel: 'المهام',
      englishLabel: 'Tasks',
    ),
    AppNavigationItem(
      index: 3,
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
      arabicLabel: 'الأمنيات',
      englishLabel: 'Wishes',
    ),
    AppNavigationItem(
      index: 2,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      arabicLabel: 'الرئيسية',
      englishLabel: 'Home',
    ),
    AppNavigationItem(
      index: 1,
      icon: Icons.card_giftcard_outlined,
      selectedIcon: Icons.card_giftcard_rounded,
      arabicLabel: 'المكافآت',
      englishLabel: 'Rewards',
    ),
    AppNavigationItem(
      index: 4,
      icon: Icons.more_horiz,
      selectedIcon: Icons.more_horiz,
      arabicLabel: 'المزيد',
      englishLabel: 'More',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<AppNavigationController>();

    final pages = <Widget>[
      navigation.isLoaded(0)
          ? AddTaskScreen(resetVersion: navigation.reselectionVersionFor(0))
          : const SizedBox.shrink(),

      navigation.isLoaded(1)
          ? const RewardManagementScreen()
          : const SizedBox.shrink(),

      navigation.isLoaded(2)
          ? const ParentDashboardScreen()
          : const SizedBox.shrink(),

      navigation.isLoaded(3)
          ? const WishlistApprovalScreen()
          : const SizedBox.shrink(),

      navigation.isLoaded(4)
          ? MoreSettingsScreen(
              isArabic: isArabic,
              onLanguageToggle: onLanguageToggle,
            )
          : const SizedBox.shrink(),
    ];

    return Scaffold(
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
