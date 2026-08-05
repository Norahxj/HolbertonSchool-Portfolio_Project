import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'core/network/dio_factory.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/services/auth_api_service.dart';
import 'features/child/widgets/child_nav.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/parent/screens/parent_main_screen.dart';

class AsalahApp extends StatefulWidget {
  const AsalahApp({super.key});

  @override
  State<AsalahApp> createState() => _AsalahAppState();
}

class _AsalahAppState extends State<AsalahApp> {
  /// Gives us access to the app's Navigator from outside a screen.
  ///
  /// We use it when the refresh token expires so that we can close
  /// any opened screens and return the user to the welcome screen.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isChild = false;

  Locale _locale = const Locale('ar');

  @override
  void initState() {
    super.initState();

    // DioFactory calls this method when the refresh token is no longer valid.
    DioFactory.onSessionExpired = _handleSessionExpired;

    _checkLogin();
  }

  /// Checks whether the user has a saved login session.
  ///
  /// It also checks whether the saved account belongs to a child
  /// or a parent so the correct navigation screen can be displayed.
  Future<void> _checkLogin() async {
    final isLoggedIn = await AuthApiService().isLoggedIn();

    bool isChild = false;

    if (isLoggedIn) {
      final childData = await SecureStorage.getChild();
      isChild = childData != null;
    }

    // The widget might have been removed while the asynchronous
    // storage operation was running.
    if (!mounted) return;

    setState(() {
      _isLoggedIn = isLoggedIn;
      _isChild = isChild;
      _isLoading = false;
    });
  }

  /// Runs when the refresh token is expired, invalid, or revoked.
  ///
  /// DioFactory already clears the tokens before calling this method.
  /// Here, we update the app state and return the user to the welcome screen.
  Future<void> _handleSessionExpired() async {
    if (!mounted) return;

    setState(() {
      _isLoggedIn = false;
      _isChild = false;
      _isLoading = false;
    });

    /*
     * Wait until Flutter finishes rebuilding the app before closing
     * any screens that may currently be open.
     */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });
  }

  /// Switches between Arabic and English.
  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
    });
  }

  bool get isArabic => _locale.languageCode == 'ar';

  @override
  void dispose() {
    /*
     * Remove the callback when this widget is disposed.
     *
     * This prevents DioFactory from trying to call an old AsalahApp
     * state object.
     */
    DioFactory.onSessionExpired = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
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

      /*
       * Directionality is applied here so it wraps every screen,
       * including screens opened using Navigator.push().
       */
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        final directionWrapped = Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child,
        );

        /*
         * On wide screens, such as Chrome on a computer, the app is
         * displayed inside a mobile-sized frame.
         */
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 500;

            if (!isWideScreen) {
              return directionWrapped;
            }

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

      home: _buildHomeScreen(),
    );
  }

  /// Chooses which screen should be displayed when the app starts
  /// or when the authentication state changes.
  Widget _buildHomeScreen() {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn) {
      return WelcomeScreen(
        isArabic: isArabic,
        onLanguageToggle: _toggleLanguage,
      );
    }

    if (_isChild) {
      return ChildNav(isArabic: isArabic, onLanguageToggle: _toggleLanguage);
    }

    return ParentMainScreen(
      isArabic: isArabic,
      onLanguageToggle: _toggleLanguage,
    );
  }
}
