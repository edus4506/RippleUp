import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/review.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/services/review_service.dart';
import 'package:t5/viewModels/user_view_model.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final String currentUserId;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    required this.currentUserId,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final canDelete =
        ReviewService.canDeleteReview(review, currentUserId) &&
        onDelete != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<Users?>(
          stream: context.read<UserViewModel>().userStream(review.userId),
          builder: (context, snapshot) {
            final user = snapshot.data;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: user?.profilePictureUrl.isNotEmpty == true
                      ? NetworkImage(user!.profilePictureUrl)
                      : null,
                  child: user?.profilePictureUrl.isEmpty ?? true
                      ? const Icon(Icons.person, size: 18)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              user?.name ?? "...",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (canDelete)
                            IconButton(
                              tooltip: 'Delete review',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: onDelete,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 18,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(review.comment),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
