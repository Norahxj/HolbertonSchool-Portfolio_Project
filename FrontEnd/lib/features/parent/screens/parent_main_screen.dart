import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/localization_extension.dart';
import '../../../core/navigation/app_bottom_navigation.dart';
import '../../../core/navigation/app_navigation_controller.dart';
import '../add_task/screens/add_task_screen.dart';
import '../dashboard/screens/parent_dashboard_screen.dart';
import '../more_settings/screens/more_settings_screen.dart';
import '../reward_management/screens/reward_management_screen.dart';
import '../wishlist/screens/wishlist_approval_screen.dart';

class ParentMainScreen extends StatelessWidget {
  final int initialIndex;
  final VoidCallback onLoggedOut;

  const ParentMainScreen({
    super.key,
    this.initialIndex = 2,
    required this.onLoggedOut,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppNavigationController(initialIndex: initialIndex),
      child: _ParentNavigationView(onLoggedOut: onLoggedOut),
    );
  }
}

class _ParentNavigationView extends StatelessWidget {
  final VoidCallback onLoggedOut;

  const _ParentNavigationView({required this.onLoggedOut});

  List<AppNavigationItem> _buildNavigationItems(BuildContext context) {
    final l10n = context.l10n;

    return [
      AppNavigationItem(
        index: 0,
        icon: Icons.list_alt_outlined,
        selectedIcon: Icons.list_alt,
        label: l10n.parentNavigationTasks,
      ),
      AppNavigationItem(
        index: 3,
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
        label: l10n.parentNavigationWishes,
      ),
      AppNavigationItem(
        index: 2,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: l10n.parentNavigationHome,
      ),
      AppNavigationItem(
        index: 1,
        icon: Icons.card_giftcard_outlined,
        selectedIcon: Icons.card_giftcard_rounded,
        label: l10n.parentNavigationRewards,
      ),
      AppNavigationItem(
        index: 4,
        icon: Icons.more_horiz,
        selectedIcon: Icons.more_horiz,
        label: l10n.parentNavigationMore,
      ),
    ];
  }

  List<Widget> _buildPages(AppNavigationController navigation) {
    return [
      navigation.isLoaded(0)
          ? AddTaskScreen(
              resetVersion: navigation.reselectionVersionFor(0),
              childrenVersion: navigation.childrenVersion,
              onTaskSaved: () {
                navigation.openTab(2);
              },
            )
          : const SizedBox.shrink(),
      navigation.isLoaded(1)
          ? RewardManagementScreen(childrenVersion: navigation.childrenVersion)
          : const SizedBox.shrink(),
      navigation.isLoaded(2)
          ? ParentDashboardScreen(
              onChildrenChanged: navigation.notifyChildrenChanged,
            )
          : const SizedBox.shrink(),
      navigation.isLoaded(3)
          ? const WishlistApprovalScreen()
          : const SizedBox.shrink(),
      navigation.isLoaded(4)
          ? MoreSettingsScreen(onLoggedOut: onLoggedOut)
          : const SizedBox.shrink(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<AppNavigationController>();
    final navigationItems = _buildNavigationItems(context);
    final pages = _buildPages(navigation);

    return Scaffold(
      body: IndexedStack(index: navigation.currentIndex, children: pages),
      bottomNavigationBar: AppBottomNavigation(
        items: navigationItems,
        currentIndex: navigation.currentIndex,
        onTap: navigation.selectTab,
      ),
    );
  }
}
