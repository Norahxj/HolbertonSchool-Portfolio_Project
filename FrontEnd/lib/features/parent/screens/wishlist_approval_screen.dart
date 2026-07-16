import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/wish_model.dart';
import '../../../services/child_api_service.dart';
import '../../../services/wishlist_api_service.dart';
import 'parent_dashboard_screen.dart';

// Wishlist Approval screen (Screen 14).
//
// Loads every child's wishes from the backend and splits them into
// pending (needs approve/reject) and approved (already decided) groups.
// ChildApiService().getChildren() is only used internally to resolve a
// child's name for the card header — it is not shown as its own list.
class WishlistApprovalScreen extends StatefulWidget {
  const WishlistApprovalScreen({super.key});

  @override
  State<WishlistApprovalScreen> createState() =>
      _WishlistApprovalScreenState();
}

// Pairs a wish with its child's name so the cards below don't need to
// look the child up themselves.
class _WishEntry {
  final WishModel wish;
  final String childName;

  _WishEntry({required this.wish, required this.childName});
}

class _WishlistApprovalScreenState extends State<WishlistApprovalScreen> {
  final ChildApiService _childApiService = ChildApiService();
  final WishlistApiService _wishlistService = WishlistApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<_WishEntry> _pendingWishes = [];
  List<_WishEntry> _approvedWishes = [];

  @override
  void initState() {
    super.initState();
    _loadWishes();
  }

  Future<void> _loadWishes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final children = await _childApiService.getChildren();

      final pending = <_WishEntry>[];
      final approved = <_WishEntry>[];

      for (final child in children) {
        final wishes = await _wishlistService.getChildWishes(child.id);
        for (final wish in wishes) {
          final entry = _WishEntry(wish: wish, childName: child.name);
          final status = wish.status.toUpperCase();
          if (status == 'PENDING') {
            pending.add(entry);
          } else if (status == 'APPROVED') {
            approved.add(entry);
          }
        }
      }

      setState(() {
        _pendingWishes = pending;
        _approvedWishes = approved;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل الأمنيات. حاول مرة أخرى.';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveWish(String wishId, int targetPoints) async {
    try {
      await _wishlistService.approveWish(wishId, targetPoints);
      _loadWishes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّرت الموافقة على الأمنية')),
        );
      }
    }
  }

  Future<void> _rejectWish(String wishId) async {
    try {
      await _wishlistService.rejectWish(wishId);
      _loadWishes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذّر رفض الأمنية')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'موافقة الأمنيات',
                          style: AppTextStyles.arabicTitle,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'راجع أمنيات أطفالك وحدّد نقاط نور المطلوبة',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_errorMessage != null)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadWishes,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                else if (_pendingWishes.isEmpty && _approvedWishes.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'لا توجد أمنيات بعد.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else ...[
                  for (final entry in _pendingWishes) ...[
                    _PendingWishCard(
                      key: ValueKey(entry.wish.id),
                      childName: entry.childName,
                      wishTitle: entry.wish.name,
                      subtitle: 'أضاف هذه الأمنية إلى قائمته',
                      startingPoints: entry.wish.targetPoints ?? 250,
                      avatarColor: const Color(0xFFFBE3EA),
                      iconColor: const Color(0xFFD1637F),
                      onApprove: (points) =>
                          _approveWish(entry.wish.id, points),
                      onReject: () => _rejectWish(entry.wish.id),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  for (final entry in _approvedWishes) ...[
                    _ApprovedWishCard(
                      childName: entry.childName,
                      wishTitle: entry.wish.name,
                      subtitle: 'تمت الموافقة على هذه الأمنية',
                      points: entry.wish.targetPoints ?? 0,
                      avatarColor: const Color(0xFFDCEBFB),
                      iconColor: const Color(0xFF4A90D9),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],

                const SizedBox(height: AppSpacing.sm),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'عند الموافقة تُخصم نقاط نور من رصيد الطفل مقابل الأمنية',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Round back button in the top-right corner, same style as other screens.
class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

// A small pill used for both the "بانتظار الموافقة" and "معتمدة" tags.
class _StatusTag extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusTag({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

// The top row shared by both cards: child name + wish title on the right,
// avatar circle on the left... wait, avatar on the far side, name next to
// it. Used by both the pending and approved cards.
class _WishHeader extends StatelessWidget {
  final String childName;
  final String wishTitle;
  final Color avatarColor;
  final Color iconColor;

  const _WishHeader({
    required this.childName,
    required this.wishTitle,
    required this.avatarColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$childName . $wishTitle',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
          child: Icon(Icons.person, color: iconColor, size: 20),
        ),
      ],
    );
  }
}

// A wish that is still waiting for the parent's decision. This is a
// StatefulWidget only because the "نقاط نور المطلوبة" value can be
// increased or decreased with the + / - buttons.
class _PendingWishCard extends StatefulWidget {
  final String childName;
  final String wishTitle;
  final String subtitle;
  final int startingPoints;
  final Color avatarColor;
  final Color iconColor;
  final ValueChanged<int> onApprove;
  final VoidCallback onReject;

  const _PendingWishCard({
    super.key,
    required this.childName,
    required this.wishTitle,
    required this.subtitle,
    required this.startingPoints,
    required this.avatarColor,
    required this.iconColor,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_PendingWishCard> createState() => _PendingWishCardState();
}

class _PendingWishCardState extends State<_PendingWishCard> {
  // The current "نقاط نور المطلوبة" (Noor points required) value. This
  // starts at whatever was passed in, and only changes when the parent
  // taps the + or - button below.
  late int requiredPoints;

  @override
  void initState() {
    super.initState();
    requiredPoints = widget.startingPoints;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WishHeader(
            childName: widget.childName,
            wishTitle: widget.wishTitle,
            avatarColor: widget.avatarColor,
            iconColor: widget.iconColor,
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              const _StatusTag(
                label: 'بانتظار الموافقة',
                backgroundColor: AppColors.primaryLight,
                textColor: AppColors.primaryDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _StepperButton(
                  icon: Icons.add,
                  isFilled: true,
                  onTap: () {
                    setState(() {
                      requiredPoints = requiredPoints + 10;
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$requiredPoints',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
                const SizedBox(width: AppSpacing.sm),
                _StepperButton(
                  icon: Icons.remove,
                  isFilled: false,
                  onTap: () {
                    // Do not let the required points go below zero.
                    if (requiredPoints > 0) {
                      setState(() {
                        requiredPoints = requiredPoints - 10;
                      });
                    }
                  },
                ),
                const Spacer(),
                const Text(
                  'نقاط نور المطلوبة',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    // Don't allow approving with 0 or negative points.
                    if (requiredPoints <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يجب أن تكون النقاط أكبر من صفر'),
                        ),
                      );
                      return;
                    }
                    widget.onApprove(requiredPoints);
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'موافقة وخصم النقاط',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.check, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onReject,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'رفض',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.close,
                          color: AppColors.textPrimary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// The small round + / - buttons next to the points value.
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool isFilled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.isFilled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isFilled ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isFilled ? Colors.white : AppColors.primaryDark,
        ),
      ),
    );
  }
}

// A wish that has already been approved. No buttons or stepper here,
// just the result: how many points were deducted from the child.
class _ApprovedWishCard extends StatelessWidget {
  final String childName;
  final String wishTitle;
  final String subtitle;
  final int points;
  final Color avatarColor;
  final Color iconColor;

  const _ApprovedWishCard({
    required this.childName,
    required this.wishTitle,
    required this.subtitle,
    required this.points,
    required this.avatarColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBFE3C6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WishHeader(
            childName: childName,
            wishTitle: wishTitle,
            avatarColor: avatarColor,
            iconColor: iconColor,
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              const _StatusTag(
                label: 'معتمدة',
                backgroundColor: AppColors.success,
                textColor: Colors.white,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Text(
                  '$points',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
                const Spacer(),
                const Text(
                  'تم خصمها من رصيده',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
