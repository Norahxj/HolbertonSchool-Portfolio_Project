import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';

void main() {
  testWidgets('AuthScreen builds successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthScreen(
          isArabic: true,
          onLanguageToggle: _emptyCallback,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
  });
}

void _emptyCallback() {}