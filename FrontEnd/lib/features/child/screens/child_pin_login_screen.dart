import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/widgets/screen_background.dart';
import '../widgets/child_nav.dart';

// Child PIN Login screen (Screen 20).
class ChildPinLoginScreen extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;

  const ChildPinLoginScreen({
    super.key,
    required this.isArabic,
    required this.onLanguageToggle,
  });

  @override
  State<ChildPinLoginScreen> createState() => _ChildPinLoginScreenState();
}

class _ChildPinLoginScreenState extends State<ChildPinLoginScreen> {
  String pin = '';
  bool isLoading = false;
  String? errorMessage;

  final TextEditingController _pinController = TextEditingController();

  final FocusNode _pinFocusNode = FocusNode();

  Future<void> _loginChild() async {
    if (pin.length != 6) {
      setState(() {
        errorMessage = widget.isArabic
            ? 'أدخل رمز الدخول كاملاً'
            : 'Enter the complete access code';
      });

      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await AuthApiService().childLogin(accessCode: pin);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChildNav()),
      );
    } on DioException catch (error) {
      if (!mounted) return;

      final responseData = error.response?.data;
      String? backendMessage;

      if (responseData is Map) {
        backendMessage = responseData['error']?.toString();
      }

      setState(() {
        errorMessage =
            backendMessage ??
            (widget.isArabic
                ? 'رمز الدخول غير صحيح'
                : 'The access code is incorrect');
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = widget.isArabic
            ? 'حدث خطأ أثناء تسجيل الدخول. حاول مرة أخرى.'
            : 'An error occurred while logging in. Please try again.';
      });

      debugPrint('Child login error: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: ScreenBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundBackButton(
                        isArabic: isArabic,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      LanguageToggle(
                        isArabic: isArabic,
                        onTap: widget.onLanguageToggle,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    isArabic ? 'أهلاً بك!' : 'Welcome!',
                    style: AppTextStyles.arabicTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    isArabic
                        ? 'أدخل الرمز الذي أعطاك إياه ولي أمرك'
                        : 'Enter the code given to you by your parent',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Align(
                    alignment: isArabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      isArabic ? 'رمز الدخول' : 'Access code',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Stack(
                    children: [
                      Row(
                        textDirection: TextDirection.ltr,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int index = 0; index < 6; index++)
                            _PinBox(
                              digit: index < pin.length ? pin[index] : '',
                            ),
                        ],
                      ),

                      Positioned.fill(
                        child: Opacity(
                          opacity: 0,
                          child: TextField(
                            controller: _pinController,
                            focusNode: _pinFocusNode,
                            enabled: !isLoading,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.left,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onChanged: (value) {
                              setState(() {
                                pin = value;
                                errorMessage = null;
                              });
                            },
                            onSubmitted: (_) {
                              if (pin.length == 6) {
                                _loginChild();
                              }
                            },
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  if (errorMessage != null) ...[
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  AppButton(
                    text: isLoading
                        ? (isArabic ? 'جاري التحقق...' : 'Verifying...')
                        : (isArabic ? 'دخول' : 'Login'),
                    onPressed: isLoading ? null : _loginChild,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.primaryGradient,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Back button displayed in the top corner.
class _RoundBackButton extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onTap;

  const _RoundBackButton({required this.isArabic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            isArabic ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

// One box in the access-code row.
class _PinBox extends StatelessWidget {
  final String digit;

  const _PinBox({required this.digit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
