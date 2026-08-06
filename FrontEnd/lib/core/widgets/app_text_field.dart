import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? errorText;
  final TextDirection? textDirection;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.textDirection,
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
    final fieldDirection =
        widget.textDirection ?? Directionality.of(context);

    final isRtl = fieldDirection == TextDirection.rtl;

    final mainIcon = Icon(
      widget.icon,
      color: AppColors.textSecondary,
    );

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
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          errorText: widget.errorText,
          floatingLabelAlignment: FloatingLabelAlignment.start,

          prefixIcon: isRtl ? passwordIcon : mainIcon,
          suffixIcon: isRtl ? mainIcon : passwordIcon,

          filled: true,
          fillColor: AppColors.inputBackground,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.error,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}