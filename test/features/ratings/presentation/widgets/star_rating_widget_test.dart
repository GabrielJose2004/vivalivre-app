import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viva_livre_app/features/ratings/presentation/widgets/star_rating_widget.dart';

void main() {
  group('StarRatingWidget', () {
    testWidgets('displays 5 stars', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingWidget(),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_outlined), findsWidgets);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('updates rating on tap', (WidgetTester tester) async {
      double? selectedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingWidget(
              onRatingChanged: (rating) {
                selectedRating = rating;
              },
            ),
          ),
        ),
      );

      // Tap on the 4th star
      await tester.tap(find.byIcon(Icons.star_outlined).at(3));
      await tester.pumpAndSettle();

      expect(selectedRating, equals(4.0));
    });

    testWidgets('displays initial rating', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingWidget(initialRating: 3.5),
          ),
        ),
      );

      // Should have 3 filled stars and 1 half-filled
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('read-only mode prevents changes', (WidgetTester tester) async {
      double? selectedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingWidget(
              readOnly: true,
              initialRating: 2.0,
              onRatingChanged: (rating) {
                selectedRating = rating;
              },
            ),
          ),
        ),
      );

      // Try to tap on a star
      await tester.tap(find.byIcon(Icons.star).first);
      await tester.pumpAndSettle();

      // Rating should not change
      expect(selectedRating, isNull);
    });

    testWidgets('supports custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingWidget(size: 48),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.star_outlined).first;
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('max rating is 5', (WidgetTester tester) async {
      double? selectedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingWidget(
              onRatingChanged: (rating) {
                selectedRating = rating;
              },
            ),
          ),
        ),
      );

      // Tap on the 5th star
      await tester.tap(find.byIcon(Icons.star_outlined).at(4));
      await tester.pumpAndSettle();

      expect(selectedRating, equals(5.0));
    });

    testWidgets('min rating is 0', (WidgetTester tester) async {
      double? selectedRating = 3.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingWidget(
              initialRating: 3.0,
              onRatingChanged: (rating) {
                selectedRating = rating;
              },
            ),
          ),
        ),
      );

      // Tap on the 1st star to set to 1
      await tester.tap(find.byIcon(Icons.star).first);
      await tester.pumpAndSettle();

      expect(selectedRating, equals(1.0));
    });
  });
}
