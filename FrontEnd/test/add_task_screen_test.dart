import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/features/parent/screens/add_task_screen.dart';

void main() {
  group('AddTaskScreen Widget Tests', () {
    testWidgets('Builds AddTaskScreen successfully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddTaskScreen(),
        ),
      );

      await tester.pump();

      expect(find.byType(AddTaskScreen), findsOneWidget);
    });

    testWidgets('Displays next button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddTaskScreen(),
        ),
      );

      await tester.pump();

      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('التالي'), findsOneWidget);
    });
  });
}