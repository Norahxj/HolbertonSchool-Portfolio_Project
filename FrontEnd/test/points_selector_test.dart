import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/parent/widgets/points_selector.dart';

void main() {
  group('PointsSelector Widget Tests', () {
    testWidgets('Builds successfully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointsSelector(
              points: 20,
              onIncrease: () {},
              onDecrease: () {},
            ),
          ),
        ),
      );

      expect(find.byType(PointsSelector), findsOneWidget);
    });

    testWidgets('Displays current points', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointsSelector(
              points: 25,
              onIncrease: () {},
              onDecrease: () {},
            ),
          ),
        ),
      );

      expect(find.text('25 نقطة'), findsOneWidget);
    });

    testWidgets('Calls onIncrease when add button is tapped', (tester) async {
      var increased = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointsSelector(
              points: 20,
              onIncrease: () => increased = true,
              onDecrease: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(increased, isTrue);
    });

    testWidgets('Calls onDecrease when remove button is tapped', (tester) async {
      var decreased = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointsSelector(
              points: 20,
              onIncrease: () {},
              onDecrease: () => decreased = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(decreased, isTrue);
    });

    testWidgets('Displays add and remove buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PointsSelector(
              points: 20,
              onIncrease: () {},
              onDecrease: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });
  });
}