import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:t5/views/dialogs/event_details_dialog.dart';
import 'package:t5/views/widgets/top_bar_tabs/notification_dropdown.dart';
import 'package:t5/views/widgets/top_bar_tabs/event_filter_button.dart';

import '../../../data/models/events/event.dart';
import '../../../viewModels/events/event_viewModel.dart';
import '../../widgets/top_bar_tabs/top_bar.dart';
import '../../widgets/event_card.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carrega a primeira página ao entrar na página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventViewModel>().loadFirstPage();
    });
  }

  void _openEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (_) => EventDetailsDialog(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventViewModel>();

    final events = viewModel.pagedEvents;

    return Scaffold(
      appBar: TopBar(
        leftWidget: NotificationDropdown(),
        title: 'Events',
        rightWidget: EventFilterButton(),
      ),
      body: viewModel.isLoading && events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? const Center(child: Text('No events found.'))
              : ListView.builder(
                  // +1 para o item "Load More" no fim
                  itemCount: events.length + (viewModel.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Último item — botão Load More
                    if (index == events.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: viewModel.isLoadingMore
                              ? const CircularProgressIndicator()
                              : TextButton.icon(
                                  onPressed: viewModel.loadMoreEvents,
                                  icon: const Icon(Icons.expand_more),
                                  label: const Text('Load more'),
                                ),
                        ),
                      );
                    }

                    final event = events[index];
                    return EventCard(
                      event: event,
                      onTap: () => _openEventDetails(context, event),
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