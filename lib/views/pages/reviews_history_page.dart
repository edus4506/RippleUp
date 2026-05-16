import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/review_history_item.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/viewModels/review_viewModel.dart';
import 'package:t5/views/dialogs/event_details_dialog.dart';

class ReviewsHistoryPage extends StatelessWidget {
  const ReviewsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reviews History')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'You need to be logged in to view your reviews history.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (_) => false,
                    );
                  },
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews History')),
      body: StreamBuilder<List<ReviewHistoryItem>>(
        stream: context.read<ReviewViewModel>().getUserReviewsHistory(
          currentUser.uid,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load reviews history.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'You have not written any reviews yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return _ReviewHistoryCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _ReviewHistoryCard extends StatelessWidget {
  final ReviewHistoryItem item;

  const _ReviewHistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => EventDetailsDialog(event: item.event),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.event.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < item.review.rating ? Icons.star : Icons.star_border,
                    size: 20,
                    color: Colors.amber,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(item.review.comment),

              const SizedBox(height: 8),

              Text(
                'Created at: ${_formatDate(item.review.createdAt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 6),

              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Open event', style: TextStyle(color: Colors.grey)),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
