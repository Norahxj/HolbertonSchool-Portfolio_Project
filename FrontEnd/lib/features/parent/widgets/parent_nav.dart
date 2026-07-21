import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/child_model.dart';
import '../../../models/user_model.dart';
import '../../../services/user_api_service.dart';
import '../screens/add_task_screen.dart';
import '../screens/more_settings_screen.dart';
import '../screens/parent_dashboard_screen.dart';
import '../screens/reward_management_screen.dart';
import '../screens/wishlist_approval_screen.dart';
import '../services/child_api_service.dart';

class ParentNav extends StatefulWidget {
  const ParentNav({super.key});

  @override
  State<ParentNav> createState() => _ParentNavState();
}

class _ParentNavState extends State<ParentNav> {
  // Home is index 2 because it is in the middle.
  int currentPageIndex = 2;

  late Future<UserModel> userFuture;
  late Future<List<ChildModel>> childrenFuture;

  @override
  void initState() {
    super.initState();

    userFuture = UserApiService().getCurrentUser();
    childrenFuture = ChildApiService().getChildren();
  }

  void refreshChildren() {
    setState(() {
      childrenFuture = ChildApiService().getChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      // Index 0
      const AddTaskScreen(),

      // Index 1
      const RewardManagementScreen(),

      // Index 2
      ParentDashboardScreen(
        userFuture: userFuture,
        childrenFuture: childrenFuture,
        onRefreshChildren: refreshChildren,
      ),

      // Index 3
      const WishlistApprovalScreen(),

      // Index 4
      MoreSettingsScreen(
        userFuture: userFuture,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentPageIndex,
        children: screens,
      ),

      bottomNavigationBar: Directionality(
        // Keeps the visual order from left to right
        // exactly as written below.
        textDirection: TextDirection.ltr,
        child: NavigationBar(
          selectedIndex: currentPageIndex,
          backgroundColor: AppColors.card,
          indicatorColor: AppColors.primaryLight,

          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },

          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(
                Icons.list_alt,
                color: AppColors.primary,
              ),
              icon: Icon(
                Icons.list_alt_outlined,
                color: AppColors.textSecondary,
              ),
              label: 'المهام',
            ),

            NavigationDestination(
              selectedIcon: Icon(
                Icons.card_giftcard,
                color: AppColors.primary,
              ),
              icon: Icon(
                Icons.card_giftcard_outlined,
                color: AppColors.textSecondary,
              ),
              label: 'المكافآت',
            ),

            NavigationDestination(
              selectedIcon: Icon(
                Icons.home,
                color: AppColors.primary,
              ),
              icon: Icon(
                Icons.home_outlined,
                color: AppColors.textSecondary,
              ),
              label: 'الرئيسية',
            ),

            NavigationDestination(
              selectedIcon: Icon(
                Icons.favorite,
                color: AppColors.primary,
              ),
              icon: Icon(
                Icons.favorite_border,
                color: AppColors.textSecondary,
              ),
              label: 'الأمنيات',
            ),

            NavigationDestination(
              selectedIcon: Icon(
                Icons.more_horiz,
                color: AppColors.primary,
              ),
              icon: Icon(
                Icons.more_horiz,
                color: AppColors.textSecondary,
              ),
              label: 'المزيد',
            ),
          ],
        ),
      ),
    );
  }
}