import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/views/dialogs/event_details_dialog.dart';
import '../../../data/models/event_status.dart';
import '../../../data/models/event.dart';
import '../../viewModels/event_viewModel.dart';
import '../dialogs/event_filter_dialog.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  void _openEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (_) => EventDetailsDialog(event: event),
    );
  }

  void _openFilterModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EventFilterDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _openFilterModal(context),
        ),
      ),

      body: StreamBuilder<List<Event>>(
        stream: context.watch<EventViewModel>().filteredEventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(child: Text('Nenhum evento encontrado.'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  onTap: () => _openEventDetails(context, event),

                  title: Text(event.title),

                  subtitle: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: '${event.city}, ${event.district} — ',
                        ),
                        TextSpan(
                          text: event.status.text,
                          style: TextStyle(
                            color: event.status.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}