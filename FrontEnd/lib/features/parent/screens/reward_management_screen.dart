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