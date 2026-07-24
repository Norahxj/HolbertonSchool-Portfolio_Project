import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../services/wishlist_api_service.dart';

// شاشة إضافة أمنية جديدة للطفل.
class AddWishlistScreen extends StatefulWidget {
  const AddWishlistScreen({super.key});

  @override
  State<AddWishlistScreen> createState() => _AddWishlistScreenState();
}

class _AddWishlistScreenState extends State<AddWishlistScreen> {
  final WishlistApiService _wishlistService = WishlistApiService();

  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  int _pendingWishesCount = 0;

  String? _nameError;
  String? _pageError;

  static const int _maximumPendingWishes = 5;

  @override
  void initState() {
    super.initState();

    _loadCurrentWishes();
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  Future<void> _loadCurrentWishes() async {
    setState(() {
      _isLoading = true;
      _pageError = null;
    });

    try {
      final wishes = await _wishlistService.getMyWishes();

      final pendingCount = wishes.where((wish) {
        return wish.status.toUpperCase() == 'PENDING';
      }).length;

      if (!mounted) return;

      setState(() {
        _pendingWishesCount = pendingCount;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _pageError = 'تعذّر تحميل قائمة الأمنيات.';
        _isLoading = false;
      });

      debugPrint('Loading wishes failed: $error');
    }
  }

  Future<void> _saveWish() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();

    setState(() {
      _nameError = null;
    });

    if (name.length < 2) {
      setState(() {
        _nameError = 'يجب أن يتكون اسم الأمنية من حرفين على الأقل.';
      });

      return;
    }

    if (name.length > 255) {
      setState(() {
        _nameError = 'اسم الأمنية طويل جدًا.';
      });

      return;
    }

    if (_hasReachedLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('وصلتِ إلى الحد الأقصى للأمنيات بانتظار المراجعة.'),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _wishlistService.createWish(name);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الأمنية بنجاح ✓')),
      );

      Navigator.pop(context, true);
    } on DioException catch (error) {
      if (!mounted) return;

      final message = _readBackendMessage(error);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'تعذّرت إضافة الأمنية. حاولي مرة أخرى.'),
        ),
      );

      debugPrint(
        'Creating wish failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء إضافة الأمنية.')),
      );

      debugPrint('Creating wish failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final backendMessage = data['error']?.toString();

      if (backendMessage?.contains('Wishlist limit reached') == true) {
        return 'وصلتِ إلى الحد الأقصى: '
            '5 أمنيات بانتظار المراجعة.';
      }

      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;

        final nameErrors = errors['name'];

        if (nameErrors is List && nameErrors.isNotEmpty) {
          return nameErrors.first.toString();
        }
      }

      return backendMessage ?? data['message']?.toString();
    }

    return null;
  }

  bool get _hasReachedLimit {
    return _pendingWishesCount >= _maximumPendingWishes;
  }

  String get _countText {
    return 'لديك $_pendingWishesCount من أصل '
        '$_maximumPendingWishes أمنيات بانتظار المراجعة';
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
              Row(
                children: [
                  const SizedBox(width: 44),

                  Expanded(
                    child: Center(
                      child: Text(
                        'إضافة أمنية',
                        style: AppTextStyles.arabicTitle,
                      ),
                    ),
                  ),

                  _RoundBackButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'اختر أمنياتك بعناية',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              if (_isLoading)
                const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _hasReachedLimit
                          ? const Color(0xFFF9DEDE)
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _countText,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _hasReachedLimit
                            ? AppColors.error
                            : AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),

              if (_pageError != null) ...[
                const SizedBox(height: AppSpacing.sm),

                Text(
                  _pageError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),

                TextButton(
                  onPressed: _loadCurrentWishes,
                  child: const Text('إعادة المحاولة'),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              const _FieldLabel('اسم الأمنية'),

              const SizedBox(height: AppSpacing.sm),

              _WishTextField(
                controller: _nameController,
                hint: 'مثال: دراجة هوائية',
                errorText: _nameError,
                enabled: !_hasReachedLimit,
              ),

              const SizedBox(height: AppSpacing.lg),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.primary,
                      size: 18,
                    ),

                    SizedBox(width: AppSpacing.sm),

                    Expanded(
                      child: Text(
                        'يمكنك إضافة حتى 5 أمنيات '
                        'بانتظار مراجعة ولي أمرك. '
                        'بعد قبول الأمنية سيحدد ولي '
                        'أمرك عدد النقاط المطلوبة لتحقيقها.',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving || _isLoading || _hasReachedLimit
                      ? null
                      : _saveWish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _hasReachedLimit
                              ? 'وصلتِ إلى الحد الأقصى'
                              : 'حفظ الأمنية',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _WishTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final bool enabled;

  const _WishTextField({
    required this.controller,
    required this.hint,
    required this.errorText,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
