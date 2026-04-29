import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/review.dart';
import 'package:t5/viewModels/review_viewModel.dart';
import 'package:t5/views/widgets/review_card.dart';
import 'package:t5/services/review_service.dart';

import '../../theme/palette.dart';

class FeedbackPage extends StatelessWidget {
  final String eventId;
  final String title;

  const FeedbackPage({super.key, required this.eventId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$title Reviews")),

      body: Column(
        children: [
          // Header
          StreamBuilder<List<Review>>(
            stream: context.read<ReviewViewModel>().getReviews(eventId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              final reviews = snapshot.data!;

              final average = ReviewService.getAverageRating(reviews);
              final total = ReviewService.getTotalReviews(reviews);
              final hasReviews = ReviewService.hasReviews(reviews);

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Palette.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Palette.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Average Rating",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        if (index < average.floor()) {
                          return const Icon(Icons.star, color: Colors.amber);
                        } else if (index < average) {
                          return const Icon(
                            Icons.star_half,
                            color: Colors.amber,
                          );
                        } else {
                          return const Icon(Icons.star_border);
                        }
                      }),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      hasReviews
                          ? "${average.toStringAsFixed(1)} ($total reviews)"
                          : "No reviews yet",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),

          // Reviews list
          Expanded(
            child: StreamBuilder<List<Review>>(
              stream: context.read<ReviewViewModel>().getReviews(eventId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reviews = snapshot.data!;

                if (reviews.isEmpty) {
                  return const Center(child: Text("No reviews yet"));
                }

                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return ReviewCard(review: reviews[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: null,
        child: const Icon(Icons.rate_review),
      ),
    );
  }
}
