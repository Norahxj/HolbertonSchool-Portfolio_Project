import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_bottom_navigation.dart';
import '../../../core/navigation/app_navigation_controller.dart';
import 'add_task_screen.dart';
import '../more_settings/screens/more_settings_screen.dart';
import 'parent_dashboard_screen.dart';
import '../reward_management/screens/reward_management_screen.dart';
import 'wishlist_approval_screen.dart';

class ParentMainScreen extends StatefulWidget {
  final int initialIndex;
  final bool isArabic;
  final VoidCallback onLanguageToggle;

  const ParentMainScreen({
    super.key,
    this.initialIndex = 2,
    this.isArabic = true,
    required this.onLanguageToggle,
  });

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  late bool _isArabic;

  @override
  void initState() {
    super.initState();
    _isArabic = widget.isArabic;
  }

  @override
  void didUpdateWidget(covariant ParentMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isArabic != widget.isArabic) {
      _isArabic = widget.isArabic;
    }
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
    });

    widget.onLanguageToggle();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppNavigationController(initialIndex: widget.initialIndex),
      child: _ParentNavigationView(
        isArabic: _isArabic,
        onLanguageToggle: _toggleLanguage,
      ),
    );
  }
}

class _ParentNavigationView extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;

  const _ParentNavigationView({
    required this.isArabic,
    required this.onLanguageToggle,
  });

  static const List<AppNavigationItem> _navigationItems = [
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
      // Tasks tab:
      // Restore the original Add Task flow.
      navigation.isLoaded(0)
          ? AddTaskScreen(
              resetVersion: navigation.reselectionVersionFor(0),
              childrenVersion: navigation.childrenVersion,
              isArabic: isArabic,
              onLanguageToggle: onLanguageToggle,
            )
          : const SizedBox.shrink(),

      navigation.isLoaded(1)
          ? RewardManagementScreen(
              isArabic: isArabic,
              childrenVersion: navigation.childrenVersion,
            )
          : const SizedBox.shrink(),

      navigation.isLoaded(2)
          ? ParentDashboardScreen(
              isArabic: isArabic,
              onChildrenChanged: navigation.notifyChildrenChanged,
            )
          : const SizedBox.shrink(),

      navigation.isLoaded(3)
          ? WishlistApprovalScreen(isArabic: isArabic)
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
