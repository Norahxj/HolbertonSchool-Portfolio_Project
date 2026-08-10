import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/navigation/app_bottom_navigation.dart';
import '../../../core/navigation/app_navigation_controller.dart';
import '../home/screens/child_home_screen.dart';
import '../progress/screens/child_progress_screen.dart';
import '../rewards/screens/child_rewards_screen.dart';
import '../wishlist/screens/child_wishlist_screen.dart';

class ChildNav extends StatelessWidget {
  final VoidCallback onLanguageToggle;
  final VoidCallback onLoggedOut;

  const ChildNav({
    super.key,
    required this.onLanguageToggle,
    required this.onLoggedOut,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppNavigationController(
        initialIndex: 0,
      ),
      child: _ChildNavigationView(
        onLanguageToggle: onLanguageToggle,
        onLoggedOut: onLoggedOut,
      ),
    );
  }
}

class _ChildNavigationView extends StatelessWidget {
  final VoidCallback onLanguageToggle;
  final VoidCallback onLoggedOut;

  const _ChildNavigationView({
    required this.onLanguageToggle,
    required this.onLoggedOut,
  });

  @override
  Widget build(BuildContext context) {
    final navigation =
        context.watch<AppNavigationController>();

    final l10n = context.l10n;

    final navigationItems = [
      AppNavigationItem(
        index: 0,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: l10n.childNavigationHome,
      ),
      AppNavigationItem(
        index: 1,
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
        label: l10n.childNavigationWishes,
      ),
      AppNavigationItem(
        index: 2,
        icon: Icons.card_giftcard_outlined,
        selectedIcon: Icons.card_giftcard_rounded,
        label: l10n.childNavigationRewards,
      ),
      AppNavigationItem(
        index: 3,
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart_rounded,
        label: l10n.childNavigationProgress,
      ),
    ];

    final pages = <Widget>[
      navigation.isLoaded(0)
          ? ChildHomeScreen(
              onLanguageToggle: onLanguageToggle,
              onLoggedOut: onLoggedOut,
            )
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
      body: IndexedStack(
        index: navigation.currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        items: navigationItems,
        currentIndex: navigation.currentIndex,
        onTap: navigation.selectTab,
      ),
    );
  }
}