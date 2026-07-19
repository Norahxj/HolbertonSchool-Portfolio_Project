import 'package:flutter/material.dart';
import 'package:frontend/models/child_model.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../services/auth_api_service.dart';
import 'child_home_screen.dart';
import 'package:frontend/services/auth_api_service.dart';

// Child PIN Login screen (Screen 20).
//
// The entered pin is kept in simple local state and, once 6 digits are
// typed, is sent to the backend as the child's access code. Tapping
// "دخول" calls AuthApiService().childLogin and only moves to the child
// home screen once that succeeds.
class ChildPinLoginScreen extends StatefulWidget {
  const ChildPinLoginScreen({super.key});

  @override
  State<ChildPinLoginScreen> createState() => _ChildPinLoginScreenState();
}

class _ChildPinLoginScreenState extends State<ChildPinLoginScreen> {
  String pin = '';
  bool isLoading = false;
  String? errorMessage;

  Future<void> _loginChild() async {
    if (pin.length != 6) {
      setState(() {
        errorMessage = "أدخل رمز الدخول كاملاً";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await AuthApiService().childLogin(accessCode: pin);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChildHomeScreen()),
      );
    } on DioException catch (e) {
      setState(() {
        errorMessage = e.response?.data["error"] ?? "رمز الدخول غير صحيح";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _addDigit(String digit) {
    // A pin code here is always 6 digits, so ignore taps after that.
    if (pin.length >= 6) {
      return;
    }
    setState(() {
      pin = pin + digit;
    });
  }

  void _removeDigit() {
    if (pin.isEmpty) {
      return;
    }
    setState(() {
      pin = pin.substring(0, pin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),

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

                Text('أهلاً بك!', style: AppTextStyles.arabicTitle),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'أدخل الرمز الذي أعطاك إياه ولي أمرك',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'رمز الدخول',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < 6; i++)
                      _PinBox(digit: i < pin.length ? pin[i] : ''),
                  ],
                ),

                if (pin.length == 6) ...[const SizedBox(height: AppSpacing.lg)],

                const SizedBox(height: AppSpacing.xl),
                if (errorMessage != null) ...[
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                _Keypad(onDigitTap: _addDigit, onBackspaceTap: _removeDigit),

                const SizedBox(height: AppSpacing.xl),

                AppButton(
                  text: isLoading ? 'جاري التحقق...' : 'دخول',
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
    );
  }
}

// One box in the "رمز الدخول" row. Shows the digit if one has been typed
// for this position, or stays empty otherwise.
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

// The "تم التعرّف عليك!" banner. Only shown once all 6 digits are typed.
class _RecognizedBanner extends StatelessWidget {
  final ChildModel child;

  const _RecognizedBanner({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'تم التعرّف عليك!',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '✦ ${child.name}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFBE3EA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_care,
              color: Color(0xFFD1637F),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// The 4x3 number keypad. Reports every tap upward through the two
// callbacks it is given, instead of holding the pin itself.
class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigitTap;
  final VoidCallback onBackspaceTap;

  const _Keypad({required this.onDigitTap, required this.onBackspaceTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _KeypadRow(onDigitTap: onDigitTap, labels: const ['3', '2', '1']),
        const SizedBox(height: AppSpacing.sm),
        _KeypadRow(onDigitTap: onDigitTap, labels: const ['6', '5', '4']),
        const SizedBox(height: AppSpacing.sm),
        _KeypadRow(onDigitTap: onDigitTap, labels: const ['9', '8', '7']),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BackspaceKey(onTap: onBackspaceTap),
            _DigitKey(label: '0', onTap: () => onDigitTap('0')),
            const SizedBox(width: 84, height: 60),
          ],
        ),
      ],
    );
  }
}

// One row of 3 number keys, built from a list of labels.
class _KeypadRow extends StatelessWidget {
  final List<String> labels;
  final ValueChanged<String> onDigitTap;

  const _KeypadRow({required this.labels, required this.onDigitTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final label in labels)
          _DigitKey(label: label, onTap: () => onDigitTap(label)),
      ],
    );
  }
}

// One number key on the keypad.
class _DigitKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DigitKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// The backspace key at the bottom-left of the keypad.
class _BackspaceKey extends StatelessWidget {
  final VoidCallback onTap;

  const _BackspaceKey({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.backspace_outlined,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
