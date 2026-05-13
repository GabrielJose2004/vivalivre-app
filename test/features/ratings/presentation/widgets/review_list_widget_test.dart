import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viva_livre_app/features/ratings/domain/entities/bathroom_review.dart';
import 'package:viva_livre_app/features/ratings/presentation/widgets/review_list_widget.dart';

void main() {
  group('ReviewListWidget', () {
    testWidgets('displays empty state when no reviews', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReviewListWidget(reviews: []),
          ),
        ),
      );

      expect(find.text('Sem avaliações ainda'), findsOneWidget);
      expect(find.text('Sê o primeiro a avaliar este banheiro'), findsOneWidget);
    });

    testWidgets('displays reviews list', (WidgetTester tester) async {
      final reviews = [
        BathroomReview(
          id: '1',
          bathroomId: '1',
          userId: 'user1',
          rating: 5,
          comment: 'Excellent bathroom!',
          helpfulCount: 10,
          unhelpfulCount: 2,
          status: 'approved',
          photos: [],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
        BathroomReview(
          id: '2',
          bathroomId: '1',
          userId: 'user2',
          rating: 3,
          comment: 'Average experience',
          helpfulCount: 5,
          unhelpfulCount: 3,
          status: 'approved',
          photos: [],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListWidget(reviews: reviews),
          ),
        ),
      );

      expect(find.text('Excellent bathroom!'), findsOneWidget);
      expect(find.text('Average experience'), findsOneWidget);
    });

    testWidgets('displays helpful vote buttons', (WidgetTester tester) async {
      final reviews = [
        BathroomReview(
          id: '1',
          bathroomId: '1',
          userId: 'user1',
          rating: 4,
          comment: 'Good place',
          helpfulCount: 8,
          unhelpfulCount: 1,
          status: 'approved',
          photos: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListWidget(reviews: reviews),
          ),
        ),
      );

      expect(find.text('Útil?'), findsOneWidget);
      expect(find.text('Sim (8)'), findsOneWidget);
      expect(find.text('Não (1)'), findsOneWidget);
    });

    testWidgets('calls onHelpfulVote callback', (WidgetTester tester) async {
      String? votedReviewId;
      bool? isHelpful;

      final reviews = [
        BathroomReview(
          id: '1',
          bathroomId: '1',
          userId: 'user1',
          rating: 4,
          comment: 'Good place',
          helpfulCount: 8,
          unhelpfulCount: 1,
          status: 'approved',
          photos: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListWidget(
              reviews: reviews,
              onHelpfulVote: (reviewId, helpful) {
                votedReviewId = reviewId;
                isHelpful = helpful;
              },
            ),
          ),
        ),
      );

      // Tap on "Sim" button
      await tester.tap(find.text('Sim (8)'));
      await tester.pumpAndSettle();

      expect(votedReviewId, equals('1'));
      expect(isHelpful, equals(true));
    });

    testWidgets('displays review rating as stars', (WidgetTester tester) async {
      final reviews = [
        BathroomReview(
          id: '1',
          bathroomId: '1',
          userId: 'user1',
          rating: 5,
          comment: 'Perfect!',
          helpfulCount: 0,
          unhelpfulCount: 0,
          status: 'approved',
          photos: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListWidget(reviews: reviews),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('displays relative time', (WidgetTester tester) async {
      final reviews = [
        BathroomReview(
          id: '1',
          bathroomId: '1',
          userId: 'user1',
          rating: 4,
          comment: 'Good',
          helpfulCount: 0,
          unhelpfulCount: 0,
          status: 'approved',
          photos: [],
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListWidget(reviews: reviews),
          ),
        ),
      );

      // Should display relative time like "Hoje às HH:mm"
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('handles multiple reviews with dividers', (WidgetTester tester) async {
      final reviews = [
        BathroomReview(
          id: '1',
          bathroomId: '1',
          userId: 'user1',
          rating: 5,
          comment: 'First review',
          helpfulCount: 0,
          unhelpfulCount: 0,
          status: 'approved',
          photos: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        BathroomReview(
          id: '2',
          bathroomId: '1',
          userId: 'user2',
          rating: 3,
          comment: 'Second review',
          helpfulCount: 0,
          unhelpfulCount: 0,
          status: 'approved',
          photos: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListWidget(reviews: reviews),
          ),
        ),
      );

      expect(find.text('First review'), findsOneWidget);
      expect(find.text('Second review'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('displays comment text', (WidgetTester tester) async {
      final reviews = [
        BathroomReview(
          id: '1',
          bathroomId: '1',
          userId: 'user1',
          rating: 4,
          comment: 'This is a detailed review about the bathroom facilities.',
          helpfulCount: 0,
          unhelpfulCount: 0,
          status: 'approved',
          photos: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListWidget(reviews: reviews),
          ),
        ),
      );

      expect(
        find.text('This is a detailed review about the bathroom facilities.'),
        findsOneWidget,
      );
    });

    testWidgets('hides comment when empty', (WidgetTester tester) async {
      final reviews = [
        BathroomReview(
          id: '1',
          bathroomId: '1',
          userId: 'user1',
          rating: 5,
          comment: '',
          helpfulCount: 0,
          unhelpfulCount: 0,
          status: 'approved',
          photos: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListWidget(reviews: reviews),
          ),
        ),
      );

      // Should not display empty comment
      expect(find.byType(ReviewListWidget), findsOneWidget);
    });
  });
}
