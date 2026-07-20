import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../screens/add_task_screen.dart';
import '../screens/more_settings_screen.dart';
import '../screens/parent_dashboard_screen.dart';
import '../screens/reward_management_screen.dart';
import '../screens/wishlist_approval_screen.dart';

class ParentNav extends StatefulWidget {
  const ParentNav({super.key});

  @override
  State<ParentNav> createState() => _ParentNavState();
}

class _ParentNavState extends State<ParentNav> {
  int currentPageIndex = 0;

  final List<Widget> screens = const [
    ParentDashboardScreen(),
    AddTaskScreen(),
    RewardManagementScreen(),
    WishlistApprovalScreen(),
    MoreSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentPageIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        indicatorColor: AppColors.primaryLight,

        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: AppColors.primary,
            ),
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.list_alt,
              color: AppColors.primary,
            ),
            icon: Icon(Icons.list_alt_outlined),
            label: 'المهام',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.card_giftcard,
              color: AppColors.primary,
            ),
            icon: Icon(Icons.card_giftcard_outlined),
            label: 'المكافآت',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.favorite,
              color: AppColors.primary,
            ),
            icon: Icon(Icons.favorite_border),
            label: 'الأمنيات',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.more_horiz,
              color: AppColors.primary,
            ),
            icon: Icon(Icons.more_horiz),
            label: 'المزيد',
          ),
        ],
      ),
    );
  }
}