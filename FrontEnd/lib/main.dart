import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/localization/locale_controller.dart';
import 'core/network/dio_factory.dart';
import 'core/storage/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إيقاظ الباكند بدون تعطيل فتح التطبيق.
  unawaited(DioFactory.warmUp());

  // تحميل التوكنز المحفوظة.
  await SecureStorage.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleController(),
      child: const AsalahApp(),
    ),
  );
}
