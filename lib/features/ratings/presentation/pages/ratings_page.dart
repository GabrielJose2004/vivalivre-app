import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rating_bloc.dart';
import '../widgets/star_rating_widget.dart';
import '../widgets/review_form_widget.dart';
import '../widgets/review_list_widget.dart';

/// Page displaying bathroom ratings, statistics, and review functionality.
///
/// Features:
/// - Display overall rating and statistics
/// - Show existing reviews with vote functionality
/// - Form to submit new reviews
/// - Loading and error states
class RatingsPage extends StatefulWidget {
  final String bathroomId;
  final String? bathroomName;

  const RatingsPage({
    super.key,
    required this.bathroomId,
    this.bathroomName,
  });

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  late RatingBloc _ratingBloc;

  @override
  void initState() {
    super.initState();
    _ratingBloc = context.read<RatingBloc>();
    _loadRatings();
  }

  void _loadRatings() {
    _ratingBloc.add(LoadBathroomReviews(bathroomId: widget.bathroomId));
    _ratingBloc.add(LoadBathroomRatingStats(widget.bathroomId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bathroomName ?? 'Avaliações'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadRatings(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Rating Stats Section
              BlocBuilder<RatingBloc, RatingState>(
                builder: (context, state) {
                  if (state is RatingLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is BathroomRatingStatsLoaded) {
                    final stats = state.stats;
                    return _RatingStatsSection(stats: stats);
                  }

                  return const SizedBox.shrink();
                },
              ),

              // Review Form Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BlocListener<RatingBloc, RatingState>(
                      listener: (context, state) {
                        if (state is ReviewCreated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Avaliação submetida com sucesso!')),
                          );
                          _loadRatings();
                        } else if (state is RatingError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      child: BlocBuilder<RatingBloc, RatingState>(
                        builder: (context, state) {
                          return ReviewFormWidget(
                            isLoading: state is ReviewAdding,
                            onSubmit: (rating, comment) {
                              _ratingBloc.add(
                                CreateReview(
                                  bathroomId: widget.bathroomId,
                                  rating: rating,
                                  title: 'Avaliação',
                                  comment: comment,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Reviews List Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Avaliações dos Utilizadores',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<RatingBloc, RatingState>(
                      builder: (context, state) {
                        if (state is RatingLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (state is BathroomReviewsLoaded) {
                          return BlocListener<RatingBloc, RatingState>(
                            listener: (context, innerState) {
                              if (innerState is HelpfulVoteRecorded) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Voto registado com sucesso')),
                                );
                              }
                            },
                            child: ReviewListWidget(
                              reviews: state.reviews,
                              onHelpfulVote: (reviewId, isHelpful) {
                                _ratingBloc.add(
                                  VoteHelpful(
                                    reviewId: reviewId,
                                    isHelpful: isHelpful,
                                  ),
                                );
                              },
                            ),
                          );
                        }

                        if (state is RatingError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadRatings,
                                    child: const Text('Tenta Novamente'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section displaying rating statistics and distribution.
class _RatingStatsSection extends StatelessWidget {
  final dynamic stats; // BathroomRatingStats

  const _RatingStatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avaliação Geral',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stats.averageRating.toStringAsFixed(1),
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            StarRatingWidget(
                              initialRating: stats.averageRating,
                              readOnly: true,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${stats.totalReviews} avaliação${stats.totalReviews != 1 ? 'ões' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RatingBarItem(
                          label: 'Limpeza',
                          value: stats.avgCleanliness,
                        ),
                        const SizedBox(height: 12),
                        _RatingBarItem(
                          label: 'Acessibilidade',
                          value: stats.avgAccessibility,
                        ),
                        const SizedBox(height: 12),
                        _RatingBarItem(
                          label: 'Espaço',
                          value: stats.avgSpaciosuneness,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Rating Distribution Chart
              if (stats.ratingDistribution != null && stats.ratingDistribution!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distribuição de Avaliações',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(5, (index) {
                        final rating = 5 - index;
                        final count = stats.ratingDistribution![rating] ?? 0;
                        final percentage = stats.totalReviews > 0
                            ? (count / stats.totalReviews * 100).toStringAsFixed(0)
                            : '0';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  '$rating',
                                  style: theme.textTheme.labelSmall,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.star, size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: stats.totalReviews > 0 ? count / stats.totalReviews : 0,
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '$percentage%',
                                  style: theme.textTheme.labelSmall,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual rating bar item.
class _RatingBarItem extends StatelessWidget {
  final String label;
  final double value;

  const _RatingBarItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = value / 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value.toStringAsFixed(1),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
