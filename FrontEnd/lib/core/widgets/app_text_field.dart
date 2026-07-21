import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final bool isPassword;
  final bool isArabic;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.isPassword = false,
    this.isArabic = true,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = false;

  @override
  void initState() {
    super.initState();

    _obscured = widget.isPassword ? true : widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection fieldDirection = widget.isArabic
        ? TextDirection.rtl
        : TextDirection.ltr;

    final Widget mainIcon = Icon(widget.icon, color: AppColors.textSecondary);

    final Widget? passwordIcon = widget.isPassword
        ? IconButton(
            icon: Icon(
              _obscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscured = !_obscured;
              });
            },
          )
        : null;

    return Directionality(
      textDirection: fieldDirection,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscured,
        keyboardType: widget.keyboardType,
        textDirection: fieldDirection,
        textAlign: widget.isArabic ? TextAlign.right : TextAlign.left,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          errorText: widget.errorText,

          // In Arabic, "start" means the right side.
          // In English, "start" means the left side.
          floatingLabelAlignment: FloatingLabelAlignment.start,

          // Arabic:
          // main icon stays on the left
          // password icon stays on the right
          //
          // English:
          // main icon stays on the left
          // password icon stays on the right
          prefixIcon: widget.isArabic ? passwordIcon : mainIcon,

          suffixIcon: widget.isArabic ? mainIcon : passwordIcon,

          filled: true,
          fillColor: AppColors.inputBackground,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          enabledBorder: OutlineInputBorder(
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
      ),
    );
  }
}
