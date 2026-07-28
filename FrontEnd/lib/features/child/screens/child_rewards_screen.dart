import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/reward_model.dart';
import '../../../services/reward_api_service.dart';

/// Child Rewards screen.
///
/// Requirement #8: All data is loaded from live API calls.
/// - GET /rewards/my  → list this child's rewards
/// - PUT /rewards/{id}/claim → claim an unlocked reward
class ChildRewardsScreen extends StatefulWidget {
  final bool isArabic;

  const ChildRewardsScreen({
    super.key,
    required this.isArabic,
  });
  @override
  State<ChildRewardsScreen> createState() => _ChildRewardsScreenState();
}

class _ChildRewardsScreenState extends State<ChildRewardsScreen> {
  final RewardApiService _rewardService = RewardApiService();

  List<RewardModel> _rewards = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rewards = await _rewardService.getMyRewards();
      if (mounted) {
        setState(() {
          _rewards = rewards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = widget.isArabic
    ? 'تعذّر تحميل المكافآت'
    : 'Could not load rewards';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _claimReward(String rewardId) async {
    try {
      await _rewardService.claimReward(rewardId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
  content: Text(
    widget.isArabic
        ? 'تم استلام المكافأة! 🎉'
        : 'Reward claimed! 🎉',
  ),
  backgroundColor: AppColors.success,
),
        );
        await _loadRewards();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
  content: Text(
    widget.isArabic
        ? 'تعذّر استلام المكافأة'
        : 'Could not claim the reward',
  ),
  backgroundColor: AppColors.error,
),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadRewards,
                      child: Text(
  widget.isArabic ? 'إعادة المحاولة' : 'Try again',
),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadRewards,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
  widget.isArabic ? 'المكافآت' : 'Rewards',
  style: AppTextStyles.arabicTitle,
  textAlign: TextAlign.center,
  textDirection:
      widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
  widget.isArabic
      ? 'مكافأة أسبوعية ترتبط بتقدّمك'
      : 'A weekly reward connected to your progress',
  style: AppTextStyles.body,
  textAlign: TextAlign.center,
  textDirection:
      widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
),
                      const SizedBox(height: AppSpacing.lg),

                      if (_rewards.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
  widget.isArabic
      ? 'لا توجد مكافآت بعد.\nتحدّث مع والديك لإضافة مكافأة!'
      : 'There are no rewards yet.\nAsk your parents to add a reward!',
  textAlign: TextAlign.center,
  textDirection:
      widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
  style: const TextStyle(
    color: AppColors.textSecondary,
  ),
),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _rewards.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final reward = _rewards[index];
                            return _RewardCard(
  reward: reward,
  isArabic: widget.isArabic,
  onClaim: reward.status == 'unlocked'
      ? () => _claimReward(reward.id)
      : null,
);
                          },
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ─── Reward Card ──────────────────────────────────────────────────────────────

class _RewardCard extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback? onClaim;
   final bool isArabic;

  const _RewardCard({required this.reward, required this.isArabic, this.onClaim});

  @override
  Widget build(BuildContext context) {
    final status = reward.status.toLowerCase();

    final isUnlocked = status == 'unlocked';
    final isClaimed = status == 'claimed';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              )
            : null,
        color: isUnlocked ? null : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
     child: Row(
  textDirection:
      isArabic ? TextDirection.rtl : TextDirection.ltr,
  children: [
    Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.white.withOpacity(0.2)
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.card_giftcard_outlined,
        color: isUnlocked ? Colors.white : AppColors.primaryDark,
        size: 22,
      ),
    ),

    const SizedBox(width: AppSpacing.sm),

    Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            reward.rewardName,
            textAlign:
                isArabic ? TextAlign.right : TextAlign.left,
            textDirection:
                isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  isUnlocked ? Colors.white : AppColors.textPrimary,
            ),
          ),
          if (reward.description != null &&
              reward.description!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              reward.description!,
              textAlign:
                  isArabic ? TextAlign.right : TextAlign.left,
              textDirection:
                  isArabic ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                fontSize: 13,
                color: isUnlocked
                    ? Colors.white70
                    : AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            _statusLabel(reward),
            textAlign:
                isArabic ? TextAlign.right : TextAlign.left,
            textDirection:
                isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 12,
              color: isUnlocked
                  ? Colors.white70
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),

    const SizedBox(width: AppSpacing.md),

    if (isUnlocked)
      ElevatedButton(
        onPressed: onClaim,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        child: Text(
          isArabic ? 'استلام' : 'Claim',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),

    if (isClaimed)
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isArabic ? '🎉 تم' : '🎉 Claimed',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.gold,
          ),
        ),
      ),
  ],
),
    );
  }

  String _statusLabel(RewardModel reward) {
  switch (reward.status.toLowerCase()) {
    case 'unlocked':
      return isArabic
          ? 'متاحة الآن! اضغط للاستلام ✓'
          : 'Available now! Tap to claim ✓';

    case 'claimed':
      return isArabic
          ? 'تم الاستلام 🎉'
          : 'Claimed 🎉';

    default:
  return isArabic
      ? 'تُفتح يوم ${_unlockDayLabel(reward.unlockDay)}'
      : 'Unlocks on ${_unlockDayLabel(reward.unlockDay)}';
  }
}
String _unlockDayLabel(int unlockDay) {
  const arabicDays = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  const englishDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  if (unlockDay < 0 || unlockDay > 6) {
    return isArabic ? 'غير محدد' : 'Not specified';
  }

  return isArabic
      ? arabicDays[unlockDay]
      : englishDays[unlockDay];
}
}
