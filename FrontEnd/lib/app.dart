import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'features/onboarding/screens/welcome_screen.dart';

class AsalahApp extends StatefulWidget {
  const AsalahApp({super.key});

  @override
  State<AsalahApp> createState() => _AsalahAppState();
}

class _AsalahAppState extends State<AsalahApp> {
  Locale _locale = const Locale('ar');

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
    });
  }

  bool get isArabic => _locale.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asalah',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(),
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
      ),
      home: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: WelcomeScreen(
          isArabic: isArabic,
          onLanguageToggle: _toggleLanguage,
        ),
      ),
    );
  }
}
