import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:t5/views/dialogs/event_details_dialog.dart';
import 'package:t5/views/widgets/top_bar_tabs/notification_dropdown.dart';
import 'package:t5/views/widgets/top_bar_tabs/event_filter_button.dart';

import '../../../data/models/events/event.dart';

import '../../../viewModels/events/event_viewModel.dart';

import '../../dialogs/event_filter_dialog.dart';

import '../../widgets/top_bar_tabs/top_bar.dart';
import '../../widgets/event_card.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final TextEditingController _searchController = TextEditingController();

  void _openEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (_) => EventDetailsDialog(event: event),
    );
  }

  /*void _openFilterModal(BuildContext context) {
    showDialog(context: context, builder: (_) => const EventFilterDialog());
  }*/

  /*void _stopSearch(BuildContext context) {
    _searchController.clear();

    FocusScope.of(context).unfocus();

    context.read<EventViewModel>().stopSearch();
  }*/

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventViewModel>();

    return Scaffold(
      appBar: TopBar(
        leftWidget: NotificationDropdown(),

        title: 'Events',

        rightWidget: EventFilterButton(),
      ),

      body: StreamBuilder<List<Event>>(
        stream: viewModel.filteredEventsStream,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return Center(
              child: Text(
                viewModel.isSearching
                    ? 'No matching events found.'
                    : 'No events found.',
              ),
            );
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
