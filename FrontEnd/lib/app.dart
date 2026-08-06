import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/localization/locale_controller.dart';
import 'core/network/dio_factory.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/services/auth_api_service.dart';
import 'features/child/widgets/child_nav.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/parent/screens/parent_main_screen.dart';
import 'l10n/app_localizations.dart';

class AsalahApp extends StatefulWidget {
  const AsalahApp({super.key});

  @override
  State<AsalahApp> createState() => _AsalahAppState();
}

class _AsalahAppState extends State<AsalahApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isChild = false;

  @override
  void initState() {
    super.initState();

    DioFactory.onSessionExpired = _handleSessionExpired;

    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final isLoggedIn = await AuthApiService().isLoggedIn();

    bool isChild = false;

    if (isLoggedIn) {
      final childData = await SecureStorage.getChild();

      isChild = childData != null;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoggedIn = isLoggedIn;
      _isChild = isChild;
      _isLoading = false;
    });
  }

  Future<void> _handleSessionExpired() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoggedIn = false;
      _isChild = false;
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });
  }

  @override
  void dispose() {
    DioFactory.onSessionExpired = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeController = context.watch<LocaleController>();

    return MaterialApp(
      navigatorKey: _navigatorKey,

      onGenerateTitle: (context) {
        return AppLocalizations.of(context).appName;
      },

      debugShowCheckedModeBanner: false,

      locale: localeController.locale,

      localizationsDelegates: AppLocalizations.localizationsDelegates,

      supportedLocales: AppLocalizations.supportedLocales,

      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(),
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
      ),

      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        final appContent = child;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 500;

            if (!isWideScreen) {
              return appContent;
            }

            return ColoredBox(
              color: const Color(0xFFDCD3EE),
              child: Center(
                child: SizedBox(
                  width: 390,
                  height: 844,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: appContent,
                  ),
                ),
              ),
            );
          },
        );
      },

      home: _buildHomeScreen(context),
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final localeController = context.read<LocaleController>();

    final isArabic = localeController.locale.languageCode == 'ar';

    void toggleLanguage() {
      localeController.toggleLocale();
    }

    if (!_isLoggedIn) {
      return WelcomeScreen(
        isArabic: isArabic,
        onLanguageToggle: toggleLanguage,
      );
    }

    if (_isChild) {
      return ChildNav(isArabic: isArabic, onLanguageToggle: toggleLanguage);
    }

    return const ParentMainScreen();
  }
}
