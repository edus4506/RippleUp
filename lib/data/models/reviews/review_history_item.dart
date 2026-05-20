import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/reviews/review.dart';

class ReviewHistoryItem {
  final Review review;
  final Event event;

  ReviewHistoryItem({required this.review, required this.event});
}
