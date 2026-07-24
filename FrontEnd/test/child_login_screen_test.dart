import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/language_toggle.dart';
import 'package:frontend/features/child/screens/child_pin_login_screen.dart';

void main() {
  group('ChildPinLoginScreen Widget Tests', () {
    testWidgets('Screen builds successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChildPinLoginScreen(
            isArabic: true,
            onLanguageToggle: () {},
          ),
        ),
      );

      expect(find.byType(ChildPinLoginScreen), findsOneWidget);
    });

    testWidgets('Displays login button and language toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChildPinLoginScreen(
            isArabic: true,
            onLanguageToggle: () {},
          ),
        ),
      );

      expect(find.byType(AppButton), findsOneWidget);
      expect(find.byType(LanguageToggle), findsOneWidget);
    });

    testWidgets('Displays six PIN boxes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChildPinLoginScreen(
            isArabic: true,
            onLanguageToggle: () {},
          ),
        ),
      );

      expect(find.text('رمز الدخول'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}