import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/child_pin_login_controller.dart';
import 'pin_box.dart';

class ChildPinLoginView extends StatelessWidget {
  final TextEditingController pinController;
  final FocusNode pinFocusNode;
  final VoidCallback onLanguageToggle;
  final Future<void> Function() onLogin;
  final String? errorMessage;

  const ChildPinLoginView({
    super.key,
    required this.pinController,
    required this.pinFocusNode,
    required this.onLanguageToggle,
    required this.onLogin,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        context.watch<ChildPinLoginController>();

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    const AppBackButton(),

                    LanguageToggle(
                      onTap: onLanguageToggle,
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                Container(
                  width: 160,
                  height: 160,
                  padding:
                      const EdgeInsets.all(8),
                  decoration:
                      const BoxDecoration(
                    color:
                        AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/child_login/child_login.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                Text(
                  context.l10n.childPinWelcome,
                  style:
                      AppTextStyles.arabicTitle,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                Text(
                  context.l10n
                      .childPinInstructions,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                Align(
                  alignment:
                      AlignmentDirectional
                          .centerStart,
                  child: Text(
                    context
                        .l10n
                        .childPinAccessCode,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                Stack(
                  children: [
                    Row(
                      textDirection:
                          TextDirection.ltr,
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        for (int i = 0;
                            i < 6;
                            i++)
                          PinBox(
                            digit: i <
                                    controller
                                        .pin.length
                                ? controller
                                    .pin[i]
                                : '',
                          ),
                      ],
                    ),

                    Positioned.fill(
                      child: TextField(
                        controller:
                            pinController,
                        focusNode:
                            pinFocusNode,
                        keyboardType:
                            TextInputType
                                .number,
                        textInputAction:
                            TextInputAction
                                .done,
                        textDirection:
                            TextDirection.ltr,
                        textAlign:
                            TextAlign.left,
                        maxLength: 6,

                        enableInteractiveSelection:
                            true,

                        style:
                            const TextStyle(
                          color:
                              Colors.transparent,
                          fontSize: 18,
                          height: 1.2,
                        ),

                        cursorColor:
                            Colors.transparent,
                        showCursor: true,

                        autocorrect: false,
                        enableSuggestions: false,

                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly,
                          LengthLimitingTextInputFormatter(
                            6,
                          ),
                        ],

                        onChanged:
                            controller.updatePin,

                        onSubmitted: (_) {
                          if (controller
                              .isComplete) {
                            onLogin();
                          }
                        },

                        decoration:
                            const InputDecoration(
                          counterText: '',
                          border:
                              InputBorder.none,
                          enabledBorder:
                              InputBorder.none,
                          focusedBorder:
                              InputBorder.none,
                          contentPadding:
                              EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),

                if (controller.isComplete)
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                if (errorMessage != null) ...[
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                ],

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                AppButton(
                  text: controller.isLoading
                      ? context.l10n
                          .childPinVerifying
                      : context.l10n
                          .childPinLogin,
                  onPressed:
                      controller.isLoading
                          ? null
                          : onLogin,
                  gradient:
                      const LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                    colors: AppColors
                        .primaryGradient,
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}