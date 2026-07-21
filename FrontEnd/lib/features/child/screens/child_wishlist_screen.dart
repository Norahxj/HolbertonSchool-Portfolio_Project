import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/wish_model.dart';
import '../../../services/wishlist_api_service.dart';
import 'add_wishlist_screen.dart';

class ChildWishlistScreen extends StatefulWidget {
  const ChildWishlistScreen({super.key});

  @override
  State<ChildWishlistScreen> createState() => _ChildWishlistScreenState();
}

class _ChildWishlistScreenState extends State<ChildWishlistScreen> {
  final WishlistApiService _wishlistService = WishlistApiService();

  List<WishModel> _wishes = [];
  bool _isLoading = true;
  String? _errorMessage;

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
      final wishes = await _wishlistService.getMyWishes();
      setState(() {
        _wishes = wishes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل الأمنيات. حاول مرة أخرى.';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteWish(String wishId) async {
    try {
      await _wishlistService.deleteWish(wishId);
      _loadWishes();
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
      _loadWishes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحقيق الأمنية بنجاح')),
        );
      }
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '—',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
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

                    // Body: loading / error / list
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
                            onDelete: () => _deleteWish(wish.id),
                            onAchieve: () => _achieveWish(wish.id),
                          );
                        },
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    // Add wish button
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddWishlistScreen(),
                          ),
                        );
                        _loadWishes();
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
          ],
        ),
      ),
    );
  }
}

// Wish Card Widget
class _WishCard extends StatelessWidget {
  final WishModel wish;
  final VoidCallback onDelete;
  final VoidCallback onAchieve;

  const _WishCard({
    required this.wish,
    required this.onDelete,
    required this.onAchieve,
  });

  String get _statusLabel {
    switch (wish.status.toUpperCase()) {
      case 'APPROVED':
        return 'مقبولة';
      case 'REJECTED':
        return 'مرفوضة';
      case 'ACHIEVED':
        return 'تحققت!';
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
    final hasProgress =
        status == 'APPROVED' &&
        wish.targetPoints != null &&
        wish.targetPoints! > 0;

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
          // Title and status
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

          // Progress bar (only for approved wishes)
          if (hasProgress) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.0,
                minHeight: 8,
                backgroundColor: AppColors.primaryLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '✦ النقاط المطلوبة: ${wish.targetPoints}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.end,
            ),
          ],

          // Action buttons
          if (status == 'APPROVED') ...[
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: onAchieve,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'لقد حققت أمنيتي!',
                style: TextStyle(color: Colors.white),
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
