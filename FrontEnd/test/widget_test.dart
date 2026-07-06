// A basic smoke test for the Asalah app.
//
// It builds the app and checks that the welcome screen shows up.

import 'package:flutter/material.dart';
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

    await tester.pumpWidget(const AsalahApp());

    expect(find.text('Asalah'), findsOneWidget);
  });
}
