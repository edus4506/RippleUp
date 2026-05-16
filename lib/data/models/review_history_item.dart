import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/review.dart';

class ReviewHistoryItem {
  final Review review;
  final Event event;

  ReviewHistoryItem({required this.review, required this.event});
}
