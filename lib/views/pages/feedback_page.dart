import 'package:flutter/material.dart';
import '../../theme/palette.dart';

class FeedbackPage extends StatelessWidget {
  final String eventId;
  final String title;

  const FeedbackPage({
    super.key,
    required this.eventId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$title Reviews"),
      ),

      body: Column(
        children: [
          // Header (future average rating + total reviews)
          Container(
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
                  children: const [
                    Icon(Icons.star, color: Colors.amber),
                    Icon(Icons.star, color: Colors.amber),
                    Icon(Icons.star, color: Colors.amber),
                    Icon(Icons.star_border),
                    Icon(Icons.star_border),
                  ],
                ),

                const SizedBox(height: 6),

                const Text(
                  "No reviews yet",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // Reviews list (empty for now)
          Expanded(
            child: Center(
              child: Text(
                "Be the first to review this event 👀",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),

      // Create Review Button (to be implemented)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: null, // to be implemented
        child: const Icon(Icons.rate_review),
      ),
    );
  }
}