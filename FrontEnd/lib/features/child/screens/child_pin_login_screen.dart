import 'package:flutter/material.dart';
import 'package:frontend/models/child_model.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/screen_background.dart';
import '../widgets/child_nav.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';

// Child PIN Login screen (Screen 20).
//
// The entered pin is kept in simple local state and, once 6 digits are
// typed, is sent to the backend as the child's access code. Tapping
// "دخول" calls AuthApiService().childLogin and only moves to the child
// home screen once that succeeds.
class ChildPinLoginScreen extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;

  const ChildPinLoginScreen({
    super.key,
    required this.isArabic,
    required this.onLanguageToggle,
  });
 @override
  State<ChildPinLoginScreen> createState() =>
      _ChildPinLoginScreenState();
}

class _ChildPinLoginScreenState
    extends State<ChildPinLoginScreen> {

  String pin = '';
  bool isLoading = false;
  String? errorMessage;
  final TextEditingController _pinController = TextEditingController();
final FocusNode _pinFocusNode = FocusNode();

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
    await AuthApiService().childLogin(
  accessCode: pin,
);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChildNav(),
      ),
    );
  } on DioException catch (e) {
    setState(() {
      errorMessage =
          e.response?.data["error"] ?? "رمز الدخول غير صحيح";
    });
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
    final isArabic =
      Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
  children: [
    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    AppBackButton(),

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
                    style: TextStyle(
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
    for (int i = 0; i < 6; i++)
      _PinBox(digit: i < pin.length ? pin[i] : ''),
  ],
),

    Positioned.fill(
      child: Opacity(
        opacity: 0,
        child: TextField(
          controller: _pinController,
          focusNode: _pinFocusNode,
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

                if (pin.length == 6) ...[
                  const SizedBox(height: AppSpacing.lg),
                ],

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

                const SizedBox(height: AppSpacing.xl),

                AppButton(
                  text: isLoading ? (isArabic ? 'جاري التحقق...' : 'Verifying...')
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
              children:[
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