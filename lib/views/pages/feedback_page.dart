import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/review.dart';
import 'package:t5/data/repositories/participation_repository.dart';
import 'package:t5/viewModels/review_viewModel.dart';
import 'package:t5/views/widgets/review_card.dart';
import 'package:t5/services/review_service.dart';

import '../../theme/palette.dart';

class FeedbackPage extends StatefulWidget {
  final String eventId;
  final String title;
  final DateTime endDate;
  final String currentUserId;

  const FeedbackPage({
    super.key,
    required this.eventId,
    required this.title,
    required this.endDate,
    required this.currentUserId
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();

}


class _FeedbackPageState extends State<FeedbackPage> {
  bool _canReview = false;
  bool _hasAlreadyReviewed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkReviewEligibility();
  }

  Future<void> _checkReviewEligibility() async {
    final eventEnded = DateTime.now().isAfter(widget.endDate);

    if (!eventEnded) {
      setState(() => _loading = false);
      return;
    }

    final participated = await context
        .read<ParticipationRepository>()
        .hasUserParticipated(widget.currentUserId, widget.eventId);

    final alreadyReviewed = await context
        .read<ReviewViewModel>()
        .hasUserReviewed(widget.eventId, widget.currentUserId);

    setState(() {
      _canReview = participated && !alreadyReviewed;
      _hasAlreadyReviewed = alreadyReviewed;
      _loading = false;
    });
  }

  void _showReviewBottomSheet() {
    int selectedRating = 0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leave a Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  // Star selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedRating = index + 1),
                        child: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedRating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a rating'),
                            ),
                          );
                          return;
                        }

                        await context.read<ReviewViewModel>().addReview(
                          widget.eventId,
                          selectedRating,
                          commentController.text.trim(),
                        );

                        if (!mounted) return;
                        Navigator.pop(context);

                        setState(() {
                          _canReview = false;
                          _hasAlreadyReviewed = true;
                        });
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.title} Reviews")),

      body: Column(
        children: [
          // Header
          StreamBuilder<List<Review>>(
            stream: context.read<ReviewViewModel>().getReviews(widget.eventId),
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
              stream: context.read<ReviewViewModel>().getReviews(widget.eventId),
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

      floatingActionButton: _loading
        ? null
        : _canReview
          ? FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: _showReviewBottomSheet,
            child: const Icon(Icons.rate_review),
            )
          : _hasAlreadyReviewed
            ? FloatingActionButton(
                backgroundColor: Colors.grey,
                onPressed: null,
                tooltip: 'Already reviewed',
                child: const Icon(Icons.check),
            )
            : null
    );
  }
}
