import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'add_task_screen.dart';
import 'more_settings_screen.dart';
import 'parent_dashboard_screen.dart';
import 'reward_management_screen.dart';
import 'wishlist_approval_screen.dart';

class ParentMainScreen extends StatefulWidget {
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
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  late int _currentIndex;
  late bool _isArabic;

  int _tasksResetVersion = 0;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;
    _isArabic = widget.isArabic;
  }

  @override
  void didUpdateWidget(covariant ParentMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Keep this screen synchronized if the language is changed
    // from another part of the app.
    if (oldWidget.isArabic != widget.isArabic) {
      setState(() {
        _isArabic = widget.isArabic;
      });
    }
  }

  void _changePage(int index) {
    // Pressing the Tasks tab again resets the Add Task form.
    if (_currentIndex == index) {
      if (index == 0) {
        setState(() {
          _tasksResetVersion++;
        });
      }

      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
    });

    // Also notify the main app so the selected language can be
    // shared with other screens.
    widget.onLanguageToggle?.call();
  }

  List<Widget> get _pages {
    return [
      AddTaskScreen(resetVersion: _tasksResetVersion),
      const RewardManagementScreen(),
      const ParentDashboardScreen(),
      const WishlistApprovalScreen(),
      MoreSettingsScreen(
        isArabic: _isArabic,
        onLanguageToggle: _toggleLanguage,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _ParentBottomNavBar(
        currentIndex: _currentIndex,
        isArabic: _isArabic,
        onTap: _changePage,
      ),
    );
  }
}

class _ParentBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isArabic;
  final ValueChanged<int> onTap;

  const _ParentBottomNavBar({
    required this.currentIndex,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 88,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  // Arabic navigation starts from the right.
                  // English navigation starts from the left.
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Appears on the far right when Arabic is selected.
                    _NavItem(
                      icon: Icons.list_alt,
                      label: isArabic ? 'المهام' : 'Tasks',
                      isSelected: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),

                    _NavItem(
                      icon: Icons.favorite_border,
                      label: isArabic ? 'الأمنيات' : 'Wishes',
                      isSelected: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),

                    // Reserved space for the raised Home button.
                    const SizedBox(width: 56),

                    _NavItem(
                      icon: Icons.card_giftcard_outlined,
                      label: isArabic ? 'المكافآت' : 'Rewards',
                      isSelected: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),

                    // Appears on the far left when Arabic is selected.
                    _NavItem(
                      icon: Icons.more_horiz,
                      label: isArabic ? 'المزيد' : 'More',
                      isSelected: currentIndex == 4,
                      onTap: () => onTap(4),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: currentIndex == 2
                              ? AppColors.primary
                              : AppColors.primaryLight,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.home_rounded,
                          color: currentIndex == 2
                              ? Colors.white
                              : AppColors.primaryDark,
                          size: 26,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        isArabic ? 'الرئيسية' : 'Home',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: currentIndex == 2
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 58,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
