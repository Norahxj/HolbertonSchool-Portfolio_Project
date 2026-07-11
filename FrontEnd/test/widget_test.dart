// A basic smoke test for the Asalah app.
//
// It builds the app and checks that the welcome screen shows up.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app.dart';

void main() {
  testWidgets('AsalahApp shows the welcome screen', (
    WidgetTester tester,
  ) async {
    // Use a normal phone-sized screen so the layout has enough room.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // The app checks secure storage for a saved login token on startup.
    // There is no real secure storage in a test, so this fakes an empty
    // one (no saved token), same as a brand new install.
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(const AsalahApp());

    // The app briefly shows a loading spinner while it checks if the user
    // is already logged in. Wait for that to finish before checking for
    // the welcome screen.
    await tester.pumpAndSettle();

    expect(find.text('Asalah'), findsOneWidget);
  });
}
