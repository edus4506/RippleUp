import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/event.dart';

import '../../viewModels/event_viewModel.dart';
import '../../viewModels/search_viewModel.dart';

import '../dialogs/event_details_dialog.dart';
import '../widgets/event_card.dart';

class SearchEventsPage extends StatelessWidget {
  const SearchEventsPage({super.key});

  void _openEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (_) => EventDetailsDialog(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchViewModel = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchViewModel.searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search events...',
            border: InputBorder.none,
          ),
          onChanged: searchViewModel.updateSearch,
        ),
      ),

      body: StreamBuilder<List<Event>>(
        stream: context.watch<EventViewModel>().eventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allEvents = snapshot.data ?? [];
          final events = searchViewModel.filterEvents(allEvents);

          if (events.isEmpty) {
            return const Center(child: Text('No matching events found.'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return EventCard(
                event: event,
                onTap: () => _openEventDetails(context, event),
              );
            },
          );
        },
      ),
    );
  }
}
