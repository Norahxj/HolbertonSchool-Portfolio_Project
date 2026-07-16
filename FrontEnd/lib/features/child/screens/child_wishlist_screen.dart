import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/wish_model.dart';
import '../../../services/wishlist_api_service.dart';
import '../../../services/point_api_service.dart';
import 'add_wishlist_screen.dart';

/// Child Wishlist screen.
///
/// Requirement #6: Points badge shows live balance from GET /points/my.
/// Progress bar uses actual currentPoints / targetPoints.
/// Requirement #5: Bottom nav is handled by IndexedStack in ChildHomeScreen
/// (this widget is now embedded as a tab, not a standalone route).
class ChildWishlistScreen extends StatefulWidget {
  const ChildWishlistScreen({super.key});

  @override
  State<ChildWishlistScreen> createState() => _ChildWishlistScreenState();
}

class _ChildWishlistScreenState extends State<ChildWishlistScreen> {
  final WishlistApiService _wishlistService = WishlistApiService();
  final PointApiService _pointService = PointApiService();

  List<WishModel> _wishes = [];
  int _points = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _wishlistService.getMyWishes(),
        _pointService.getMyPoints(),
      ]);
      if (mounted) {
        setState(() {
          _wishes = results[0] as List<WishModel>;
          _points = results[1] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ أثناء تحميل البيانات. حاول مرة أخرى.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteWish(String wishId) async {
    try {
      await _wishlistService.deleteWish(wishId);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر حذف الأمنية')),
        );
      }
    }
  }

  Future<void> _achieveWish(String wishId) async {
    try {
      await _wishlistService.achieveWish(wishId);
await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر تحقيق الأمنية — تحقق من رصيد نقاطك'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  // Live points badge (Requirement #6)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLoading ? '—' : '$_points',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.auto_awesome,
                          color: AppColors.gold,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'قائمة أمنياتي',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.arabicTitle,
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'اجمع نقاط نور لتحقيق أمنياتك',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Body ──────────────────────────────────────────────────────
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
                        onPressed: _loadData,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              else if (_wishes.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'لا توجد أمنيات بعد.\nأضف أمنيتك الأولى!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _wishes.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final wish = _wishes[index];
                    return _WishCard(
                      wish: wish,
                      currentPoints: _points,
                      onDelete: () => _deleteWish(wish.id),
                      onAchieve: () => _achieveWish(wish.id),
                    );
                  },
                ),

              const SizedBox(height: AppSpacing.xl),

              // ── Add wish button ────────────────────────────────────────────
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddWishlistScreen(),
                    ),
                  );
                  await _loadData();
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'إضافة أمنية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Icon(Icons.add, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Wish Card ────────────────────────────────────────────────────────────────

class _WishCard extends StatelessWidget {
  final WishModel wish;
  final int currentPoints;
  final VoidCallback onDelete;
  final VoidCallback onAchieve;

  const _WishCard({
    required this.wish,
    required this.currentPoints,
    required this.onDelete,
    required this.onAchieve,
  });

  String get _statusLabel {
    switch (wish.status.toUpperCase()) {
      case 'APPROVED':
        return 'مقبولة ✓';
      case 'REJECTED':
        return 'مرفوضة ✗';
      case 'ACHIEVED':
        return 'تحققت! 🌟';
      default:
        return 'في الانتظار...';
    }
  }

  Color get _statusColor {
    switch (wish.status.toUpperCase()) {
      case 'APPROVED':
        return AppColors.success;
      case 'REJECTED':
        return Colors.red;
      case 'ACHIEVED':
        return AppColors.gold;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = wish.status.toUpperCase();
    final target = wish.targetPoints;
    final hasProgress =
        status == 'APPROVED' && target != null && target > 0;

    // Requirement #6: use actual currentPoints / targetPoints for progress
    final progressValue = hasProgress
        ? (currentPoints / target).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title + status + icon row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      wish.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusLabel,
                      style: TextStyle(fontSize: 12, color: _statusColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.star,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),

          // Progress bar (only for approved wishes with a target)
          if (hasProgress) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                backgroundColor: AppColors.primaryLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الهدف: $target نقطة',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'لديك: $currentPoints نقطة',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          // Action buttons
          if (status == 'APPROVED') ...[
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: target != null && currentPoints >= target
    ? onAchieve
    : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                target == null
    ? 'لم يتم تحديد النقاط المطلوبة'
    : currentPoints >= target
        ? 'لقد حققت أمنيتي! 🌟'
        : 'اجمع المزيد من النقاط',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],

          if (status == 'PENDING' || status == 'REJECTED') ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 18,
              ),
              label: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    );
  }
}
