import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/localization/locale_controller.dart';
import 'l10n/app_localizations.dart';

import 'package:flutter/material.dart';

import 'app.dart';
import 'core/network/dio_factory.dart';
import 'core/storage/secure_storage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleController(),
      child: const MyApp(),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start waking the backend without delaying the app.
  unawaited(DioFactory.warmUp());

  // Load saved tokens once, then keep them in memory.
  await SecureStorage.initialize();

  runApp(const AsalahApp());
}
