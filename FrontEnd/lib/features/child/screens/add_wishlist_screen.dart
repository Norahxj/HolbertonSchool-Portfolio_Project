import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../services/wishlist_api_service.dart';

class AddWishlistScreen extends StatefulWidget {
  const AddWishlistScreen({super.key});

  @override
  State<AddWishlistScreen> createState() => _AddWishlistScreenState();
}

class _AddWishlistScreenState extends State<AddWishlistScreen> {
  final TextEditingController nameController = TextEditingController();
  int selectedIconIndex = 3;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _saveWish() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة اسم الأمنية')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await WishlistApiService().createWish(name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة الأمنية بنجاح ✓')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ. تحقق من الاتصال وحاول مرة أخرى.'),
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
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'إضافة أمنية',
                        style: AppTextStyles.arabicTitle,
                      ),
                    ),
                  ),
                  _RoundBackButton(onTap: () => Navigator.pop(context)),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'اختر أمنياتك بعناية',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'أضف أمنيتك المفضلة',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              const _FieldLabel('اسم الأمنية'),
              const SizedBox(height: AppSpacing.sm),
              _WishTextField(
                controller: nameController,
                hint: 'مثال: دراجة هوائية',
              ),

              const SizedBox(height: AppSpacing.lg),

              const _FieldLabel('الأيقونة'),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _IconOption(
                    icon: Icons.emoji_events,
                    backgroundColor: const Color(0xFFDFF3E4),
                    iconColor: const Color(0xFF4CAF50),
                    isSelected: selectedIconIndex == 0,
                    onTap: () {
                      setState(() {
                        selectedIconIndex = 0;
                      });
                    },
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _IconOption(
                    icon: Icons.card_giftcard,
                    backgroundColor: AppColors.primaryLight,
                    iconColor: AppColors.primary,
                    isSelected: selectedIconIndex == 1,
                    onTap: () {
                      setState(() {
                        selectedIconIndex = 1;
                      });
                    },
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _IconOption(
                    icon: Icons.favorite,
                    backgroundColor: const Color(0xFFFBE3EA),
                    iconColor: const Color(0xFFD1637F),
                    isSelected: selectedIconIndex == 2,
                    onTap: () {
                      setState(() {
                        selectedIconIndex = 2;
                      });
                    },
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _IconOption(
                    icon: Icons.star,
                    backgroundColor: const Color(0xFFFCE7D2),
                    iconColor: const Color(0xFFDE9A3E),
                    isSelected: selectedIconIndex == 3,
                    onTap: () {
                      setState(() {
                        selectedIconIndex = 3;
                      });
                    },
                  ),
                ],
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
                        'اختر أمنياتك بعناية. يمكنك إضافة 3 أمنيات كحد أقصى في قائمتك.',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              GestureDetector(
                onTap: _isLoading ? null : _saveWish,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'حفظ الأمنية',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
  final int maxLines;

  const _WishTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _IconOption extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconOption({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: iconColor, width: 2) : null,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
