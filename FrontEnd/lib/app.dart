import 'package:flutter/material.dart';
import 'package:frontend/services/auth_api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/child/widgets/child_nav.dart';
import 'core/storage/secure_storage.dart';
import 'features/parent/screens/parent_main_screen.dart';

class AsalahApp extends StatefulWidget {
  const AsalahApp({super.key});

  @override
  State<AsalahApp> createState() => _AsalahAppState();
}

class _AsalahAppState extends State<AsalahApp> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isChild = false;

  Locale _locale = const Locale('ar');

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final isLoggedIn = await AuthApiService().isLoggedIn();
    bool isChild = false;
    if (isLoggedIn) {
      final childData = await SecureStorage.getChild();
      isChild = childData != null;
    }
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isChild = isChild;
      _isLoading = false;
    });
  }

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
      // RTL/LTR fix: Directionality is applied here in builder so it wraps
      // ALL screens including those pushed via Navigator.push/pushReplacement.
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final Widget directionWrapped = Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child,
        );
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 500;
            if (!isWideScreen) return directionWrapped;
            return ColoredBox(
              color: const Color(0xFFDCD3EE),
              child: Center(
                child: SizedBox(
                  width: 390,
                  height: 844,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: directionWrapped,
                  ),
                ),
              ),
            );
          },
        );
      },
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _isLoggedIn
              ? (_isChild
                  ? const ChildNav()
                  : ParentMainScreen(
    isArabic: isArabic,
    onLanguageToggle: _toggleLanguage,
  ))
              : WelcomeScreen(
                  isArabic: isArabic,
                  onLanguageToggle: _toggleLanguage,
                ),
    );
  }
}
