import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/language_toggle.dart';

class LanguageRow extends StatelessWidget {
  const LanguageRow({super.key});

  @override
  Widget build(BuildContext context) {

    final toggleLocale =
        context.read<LocaleController>().toggleLocale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: toggleLocale,
        child: Padding(
          padding:
              const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.language,
                  color: AppColors.primaryDark,
                  size: 20,
                ),
              ),

              const SizedBox(
                width: AppSpacing.md,
              ),

              Expanded(
                child: Text(
                  context.l10n.language,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ),

              LanguageToggle(
                onTap: toggleLocale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}