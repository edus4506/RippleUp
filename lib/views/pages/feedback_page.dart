import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/review.dart';
import 'package:t5/data/repositories/participation_repository.dart';
import 'package:t5/viewModels/review_viewModel.dart';
import 'package:t5/views/widgets/review_card.dart';
import 'package:t5/services/review_service.dart';
import 'package:t5/services/sort_review.dart';
import 'package:t5/services/sort_review_service.dart';

import '../../theme/palette.dart';

export 'package:t5/services/sort_review.dart';

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
    required this.currentUserId,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool _canReview = false;
  bool _hasAlreadyReviewed = false;
  bool _loading = true;

  ReviewSortOption _sortOption = ReviewSortOption.mostRecent;

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

    if (!mounted) return;

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

  Future<void> _confirmDeleteReview(Review review) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete review?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final deleted = await context.read<ReviewViewModel>().deleteReview(
      widget.eventId,
      review,
      widget.currentUserId,
    );

    if (!mounted) return;

    if (deleted) {
      setState(() {
        _canReview = true;
        _hasAlreadyReviewed = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review deleted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only delete your own review')),
      );
    }
  }

  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Sort by: ', style: TextStyle(color: Colors.grey)),
          DropdownButton<ReviewSortOption>(
            value: _sortOption,
            underline: const SizedBox(),
            items: ReviewSortOption.values.map((option) {
              return DropdownMenuItem(value: option, child: Text(option.label));
            }).toList(),
            onChanged: (option) {
              if (option != null) {
                setState(() => _sortOption = option);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsContent(List<Review> reviews) {
    final average = ReviewService.getAverageRating(reviews);
    final total = ReviewService.getTotalReviews(reviews);
    final hasReviews = ReviewService.hasReviews(reviews);

    if (!hasReviews) {
      return const Center(child: Text("No reviews yet"));
    }

    final sortedReviews = SortReviewService.apply(reviews, _sortOption);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Palette.border),
          ),
          child: Column(
            children: [
              const Text(
                "Average Rating",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  if (index < average.floor()) {
                    return const Icon(Icons.star, color: Colors.amber);
                  } else if (index < average) {
                    return const Icon(Icons.star_half, color: Colors.amber);
                  } else {
                    return const Icon(Icons.star_border);
                  }
                }),
              ),
              const SizedBox(height: 6),
              Text(
                "${average.toStringAsFixed(1)} ($total reviews)",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        _buildSortDropdown(),

        Expanded(
          child: ListView.builder(
            itemCount: sortedReviews.length,
            itemBuilder: (context, index) {
              final review = sortedReviews[index];

              return ReviewCard(
                review: review,
                currentUserId: widget.currentUserId,
                onDelete: () => _confirmDeleteReview(review),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.title} Reviews")),
      body: StreamBuilder<List<Review>>(
        stream: context.read<ReviewViewModel>().getReviews(widget.eventId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data!;

          return _buildReviewsContent(reviews);
        },
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
          : null,
    );
  }
}
