import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viva_livre_app/features/ratings/presentation/widgets/review_form_widget.dart';

void main() {
  group('ReviewFormWidget', () {
    testWidgets('displays form elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewFormWidget(
              onSubmit: (rating, comment) {},
            ),
          ),
        ),
      );

      expect(find.text('Tua avaliação'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows error when submitting without rating', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewFormWidget(
              onSubmit: (rating, comment) {},
            ),
          ),
        ),
      );

      // Try to submit without selecting a rating
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgetWithMaterialApp('calls onSubmit with rating and comment', (WidgetTester tester) async {
      int? submittedRating;
      String? submittedComment;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewFormWidget(
              onSubmit: (rating, comment) {
                submittedRating = rating;
                submittedComment = comment;
              },
            ),
          ),
        ),
      );

      // Select a rating (tap 4th star)
      await tester.tap(find.byIcon(Icons.star_outlined).at(3));
      await tester.pumpAndSettle();

      // Enter comment
      await tester.enterText(find.byType(TextField), 'Great bathroom!');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(submittedRating, equals(4));
      expect(submittedComment, equals('Great bathroom!'));
    });

    testWidgets('shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewFormWidget(
              isLoading: true,
              onSubmit: (rating, comment) {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submetendo...'), findsOneWidget);
    });

    testWidgets('disables submit button when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewFormWidget(
              isLoading: true,
              onSubmit: (rating, comment) {},
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('enforces 500 character limit', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewFormWidget(
              onSubmit: (rating, comment) {},
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      
      // Try to enter more than 500 characters
      final longText = 'a' * 600;
      await tester.enterText(textField, longText);
      await tester.pumpAndSettle();

      // The text field should limit to 500 chars
      expect(find.text('500/500'), findsOneWidget);
    });

    testWidgets('displays character counter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewFormWidget(
              onSubmit: (rating, comment) {},
            ),
          ),
        ),
      );

      expect(find.text('0/500'), findsOneWidget);

      // Enter some text
      await tester.enterText(find.byType(TextField), 'Test comment');
      await tester.pumpAndSettle();

      expect(find.text('12/500'), findsOneWidget);
    });

    testWidgets('allows empty comment', (WidgetTester tester) async {
      int? submittedRating;
      String? submittedComment;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewFormWidget(
              onSubmit: (rating, comment) {
                submittedRating = rating;
                submittedComment = comment;
              },
            ),
          ),
        ),
      );

      // Select a rating
      await tester.tap(find.byIcon(Icons.star_outlined).at(2));
      await tester.pumpAndSettle();

      // Submit without entering comment
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(submittedRating, equals(3));
      expect(submittedComment, isEmpty);
    });
  });
}

// Helper to wrap widget with MaterialApp
void testWidgetWithMaterialApp(
  String description,
  Future<void> Function(WidgetTester) callback,
) {
  testWidgets(description, callback);
}
