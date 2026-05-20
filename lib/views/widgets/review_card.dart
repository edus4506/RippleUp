import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/routes/app_routes.dart';

import 'package:t5/data/models/reviews/review.dart';
import 'package:t5/data/models/social/user.dart';
import 'package:t5/services/reviews/review_service.dart';
import 'package:t5/viewModels/social/user_view_model.dart';

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

  void _goToProfile(BuildContext context) {
    if (review.userId == currentUserId) return;

    Navigator.pushNamed(
      context,
      AppRoutes.publicProfile,
      arguments: {'userId': review.userId},
    );
  }

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
            final isOtherUser = review.userId != currentUserId;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: isOtherUser ? () => _goToProfile(context) : null,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: user?.profilePictureUrl.isNotEmpty == true
                        ? NetworkImage(user!.profilePictureUrl)
                        : null,
                    child: user?.profilePictureUrl.isEmpty ?? true
                        ? const Icon(Icons.person, size: 18)
                        : null,
                  ),
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
                            child: GestureDetector(
                              onTap: isOtherUser
                                  ? () => _goToProfile(context)
                                  : null,
                              child: Text(
                                user?.name ?? "...",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: isOtherUser
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
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
