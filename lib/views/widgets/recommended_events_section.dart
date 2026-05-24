import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/events/event.dart';
import 'package:t5/viewModels/events/recommended_event_viewModel.dart';
import 'package:t5/views/dialogs/event_details_dialog.dart';
import 'package:t5/views/widgets/event_card.dart';

class RecommendedEventsSection extends StatefulWidget {
  const RecommendedEventsSection({super.key});

  @override
  State<RecommendedEventsSection> createState() =>
      _RecommendedEventsSectionState();
}

class _RecommendedEventsSectionState extends State<RecommendedEventsSection> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendedEventViewModel>().loadRecommendedEvents(
        limit: 15,
      );
    });
  }

  void _openEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (_) => EventDetailsDialog(event: event),
    );
  }

  void _viewMore(BuildContext context) {
    context.read<RecommendedEventViewModel>().refreshRecommendations();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loading new recommendations...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendedEventViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    'Loading recommendations...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        if (viewModel.errorMessage != null && viewModel.hasNoData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 48),
                  const SizedBox(height: 12),
                  Text(
                    viewModel.errorMessage ?? 'No recommendations available',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.loadRecommendedEvents(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (viewModel.recommendedEvents.isEmpty) {
          return const SizedBox.shrink();
        }

        final displayedEvents = viewModel.recommendedEvents.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
              child: Text(
                'Recommended for You',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...displayedEvents.map(
              (event) => EventCard(
                event: event,
                onTap: () => _openEventDetails(context, event),
              ),
            ),

            if (viewModel.recommendedEvents.length > 5)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => _viewMore(context),
                    icon: const Icon(Icons.expand_more),
                    label: const Text('View more'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
