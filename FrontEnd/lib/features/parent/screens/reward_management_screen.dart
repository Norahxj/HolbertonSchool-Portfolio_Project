import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import 'add_reward_screen.dart';

// Reward Management screen (Screen 15).
//
// This first pass is static/placeholder only: the child list, the quick
// add categories, and the button are all hardcoded. No backend calls
// happen here yet (see the TODO comment below).
class RewardManagementScreen extends StatelessWidget {
  const RewardManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'إدارة المكافآت',
                  style: AppTextStyles.arabicTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'مكافآت أسبوعية تُمنح حسب أداء الطفل ورضا الوالدين',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

                const _ChildSelector(),

                const SizedBox(height: AppSpacing.lg),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'إضافة سريعة',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                const _QuickAddCategory(
                  icon: Icons.shopping_bag_outlined,
                  label: 'نزهات وأنشطة عائلية',
                ),
                const SizedBox(height: AppSpacing.md),
                const _QuickAddCategory(
                  icon: Icons.bookmark_border,
                  label: 'ألعاب وهدايا',
                ),
                const SizedBox(height: AppSpacing.md),
                const _QuickAddCategory(
                  icon: Icons.access_time,
                  label: 'وقت وترفيه',
                ),
                const SizedBox(height: AppSpacing.md),
                const _QuickAddCategory(
                  icon: Icons.favorite_border,
                  label: 'امتيازات خاصة',
                ),

                const SizedBox(height: AppSpacing.xl),

                const _AddRewardButton(),

                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

// Row of tappable child chips at the top of the screen. Tapping a chip
// toggles its checkmark using simple local state (no backend yet).
class _ChildSelector extends StatefulWidget {
  const _ChildSelector();

  @override
  State<_ChildSelector> createState() => _ChildSelectorState();
}

class _ChildSelectorState extends State<_ChildSelector> {
  // Placeholder starting values. In the real app this will come from the
  // backend (which children the parent has, and which are selected).
  bool isKhaledSelected = false;
  bool isSalmanSelected = true;
  bool isSaraSelected = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ChildChip(
          name: 'خالد',
          avatarColor: const Color(0xFFDFF3E4),
          iconColor: const Color(0xFF4CAF50),
          isSelected: isKhaledSelected,
          onTap: () {
            setState(() {
              isKhaledSelected = !isKhaledSelected;
            });
          },
        ),
        _ChildChip(
          name: 'سلمان',
          avatarColor: const Color(0xFFDCEBFB),
          iconColor: const Color(0xFF4A90D9),
          isSelected: isSalmanSelected,
          onTap: () {
            setState(() {
              isSalmanSelected = !isSalmanSelected;
            });
          },
        ),
        _ChildChip(
          name: 'سارة',
          avatarColor: const Color(0xFFFBE3EA),
          iconColor: const Color(0xFFD1637F),
          isSelected: isSaraSelected,
          onTap: () {
            setState(() {
              isSaraSelected = !isSaraSelected;
            });
          },
        ),
      ],
    );
  }
}

// One child avatar + name, with a small checkmark badge when selected.
class _ChildChip extends StatelessWidget {
  final String name;
  final Color avatarColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildChip({
    required this.name,
    required this.avatarColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: iconColor, size: 24),
                ),
                if (isSelected)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// One "quick add" category: a label with an icon, and a placeholder box
// below it where suggested rewards will appear later. The mockup uses a
// dashed border here; we use a plain light border to keep the code simple.
class _QuickAddCategory extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAddCategory({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(icon, color: AppColors.primaryDark, size: 18),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'ستظهر هنا المكافآت المقترحة',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// Full-width "Add reward" button at the bottom of the screen.
class _AddRewardButton extends StatelessWidget {
  const _AddRewardButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddRewardScreen()),
        );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: AppSpacing.sm),
            Text(
              'إضافة مكافأة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom navigation bar shown on this screen, with "المكافآت" highlighted
// as the active tab. Tapping the floating home button takes the parent
// back to the dashboard using Navigator.pop, since this screen was opened
// from there with Navigator.push.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

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
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(icon: Icons.more_horiz, label: 'المزيد'),
                    _NavItem(icon: Icons.favorite_border, label: 'الأمنيات'),
                    SizedBox(width: 56),
                    _NavItem(
                      icon: Icons.card_giftcard_outlined,
                      label: 'المكافآت',
                      isActive: true,
                    ),
                    _NavItem(
                      icon: Icons.list_alt,
                      label: 'المهام',
                      badgeCount: 2,
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
                  onTap: () {
                    // This screen was opened from the Parent Dashboard with
                    // Navigator.push, so popping it returns to that screen.
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'الرئيسية',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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

// One icon + label pair inside the bottom navigation bar. Set isActive to
// true to draw it in the highlighted color (used for "المكافآت" here).
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int? badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = isActive ? AppColors.primary : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: itemColor, size: 22),
            if (badgeCount != null)
              Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: itemColor,
          ),
        ),
      ],
    );
  }
}
