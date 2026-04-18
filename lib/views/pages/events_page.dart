import 'package:flutter/material.dart';
import 'package:t5/views/pages/event_details_page.dart';
import '../../../data/models/event.dart';
import '../../../data/repositories/event_repository.dart';
import 'create_event_page.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  void _openCreateEvent(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateEventPage(
        nextId: 0,
        onCreate: (Event event) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento criado com sucesso!')),
          );
        },
      ),
    );
  }

  void _openEventDetails(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateEvent(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Event>>(
        stream: EventRepository().listenToEvents(),
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
                  subtitle: Text('${event.city}, ${event.district} — ${event.eventStatus}'),
                  trailing: Text('${event.currentUsers}/${event.maxUsers}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}