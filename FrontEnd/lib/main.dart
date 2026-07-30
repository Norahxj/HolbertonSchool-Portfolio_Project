import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'core/network/dio_factory.dart';
import 'core/storage/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start waking the backend without delaying the app.
  unawaited(DioFactory.warmUp());

  // Load saved tokens once, then keep them in memory.
  await SecureStorage.initialize();

  runApp(const AsalahApp());
}
