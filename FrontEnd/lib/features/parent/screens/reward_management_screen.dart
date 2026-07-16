import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import 'add_reward_screen.dart';
import 'package:dio/dio.dart';
import 'package:frontend/models/child_model.dart';
import 'package:frontend/services/child_api_service.dart';
import 'package:frontend/models/reward_suggestion_model.dart';
import 'package:frontend/services/reward_api_service.dart';

// Reward Management screen (Screen 15).
//
// This first pass is static/placeholder only: the child list, the quick
// add categories, and the button are all hardcoded. No backend calls
// happen here yet (see the TODO comment below).
class RewardManagementScreen extends StatefulWidget {
  const RewardManagementScreen({super.key});

  @override
  State<RewardManagementScreen> createState() =>
      _RewardManagementScreenState();
}

class _RewardManagementScreenState
    extends State<RewardManagementScreen> {
  final ChildApiService _childApiService = ChildApiService();
  final RewardApiService _rewardApiService = RewardApiService();

  List<ChildModel> children = [];
  String? selectedChildId;
  List<RewardSuggestionModel> rewardSuggestions = [];
bool isLoadingSuggestions = false;
String? suggestionsError;

  bool isLoadingChildren = true;
  String? childrenError;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final data = await _childApiService.getChildren();

      if (!mounted) return;

      setState(() {
        children = data;
        isLoadingChildren = false;
      });
    } on DioException {
      if (!mounted) return;

      setState(() {
        childrenError = 'تعذر تحميل الأطفال';
        isLoadingChildren = false;
      });
    }
  }
Future<void> _loadRewardSuggestions() async {
  if (selectedChildId == null) return;

  setState(() {
    isLoadingSuggestions = true;
    suggestionsError = null;
    rewardSuggestions = [];
  });

  try {
    final suggestions =
        await _rewardApiService.getRewardSuggestions(
      lang: 'ar',
      count: 5,
    );

    if (!mounted) return;

    setState(() {
      rewardSuggestions = suggestions;
    });
  } on DioException catch (e) {
    if (!mounted) return;

    setState(() {
      suggestionsError =
          e.response?.data?['error']?.toString() ??
          'تعذر تحميل المكافآت المقترحة';
    });
  } finally {
    if (mounted) {
      setState(() {
        isLoadingSuggestions = false;
      });
    }
  }
}
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

                if (isLoadingChildren)
  const Center(
    child: CircularProgressIndicator(),
  )
else if (childrenError != null)
  Center(
    child: Text(
      childrenError!,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 13,
      ),
    ),
  )
else if (children.isEmpty)
  const Center(
    child: Text(
      'لا يوجد أطفال بعد. أضف طفلًا أولًا.',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
    ),
  )
else
  Wrap(
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.md,
    children: children.map((child) {
      final isSelected = selectedChildId == child.id;

      return _ChildChip(
        name: child.name,
        avatarColor: AppColors.primaryLight,
        iconColor: AppColors.primary,
        isSelected: isSelected,
        onTap: () {
  setState(() {
    selectedChildId = child.id;
  });

  _loadRewardSuggestions();
},
      );
    }).toList(),
  ),

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

                if (selectedChildId == null)
  Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: Text(
      'اختر طفلًا أولًا لعرض المكافآت المقترحة',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade600,
      ),
    ),
  )
else if (isLoadingSuggestions)
  const Center(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: CircularProgressIndicator(),
    ),
  )
else if (suggestionsError != null)
  Column(
    children: [
      Text(
        suggestionsError!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 13,
        ),
      ),
      TextButton(
        onPressed: _loadRewardSuggestions,
        child: const Text('إعادة المحاولة'),
      ),
    ],
  )
else
  _QuickAddCategory(
    suggestions: rewardSuggestions,
    onSuggestionTap: (suggestion) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddRewardScreen(
  childId: selectedChildId!,
  suggestion: suggestion,
),
        ),
      );
    },
  ),

                const SizedBox(height: AppSpacing.xl),

                _AddRewardButton(
  selectedChildId: selectedChildId,
),

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
  final List<RewardSuggestionModel> suggestions;
  final ValueChanged<RewardSuggestionModel> onSuggestionTap;

  const _QuickAddCategory({
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: suggestions.isEmpty
          ? const Text(
              'لا توجد مكافآت مقترحة حاليًا',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          : Column(
              children: [
                for (int i = 0; i < suggestions.length; i++) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      onSuggestionTap(suggestions[i]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            size: 19,
                            color: AppColors.primary,
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  suggestions[i].rewardName,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  suggestions[i].description,
                                  textAlign: TextAlign.right,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (i != suggestions.length - 1)
                    const Divider(
                      height: 1,
                      color: AppColors.border,
                    ),
                ],
              ],
            ),
    );
  }
}
// Full-width "Add reward" button at the bottom of the screen.
class _AddRewardButton extends StatelessWidget {
  final String? selectedChildId;

  const _AddRewardButton({
    required this.selectedChildId,
  });
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
  builder: (_) => AddRewardScreen(
    childId: selectedChildId!,
  ),
),
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

