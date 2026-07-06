import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get logo => GoogleFonts.lemonada(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
      );

  static TextStyle get logoArabic => GoogleFonts.lemonada(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark,
      );

  static TextStyle get arabicTitle => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get englishTitle => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.cairo(
        fontSize: 15,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get button => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle get cardTitle => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle get cardSubtitle => GoogleFonts.cairo(
        fontSize: 14,
        color: Colors.white,
      );
}
