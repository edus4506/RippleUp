import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/viewModels/favorite_view_model.dart';
import 'package:t5/views/dialogs/event_details_dialog.dart';
import '../event_card.dart';

class FavoriteEventsWidget extends StatelessWidget {
  const FavoriteEventsWidget({super.key});

  void _openEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (_) => EventDetailsDialog(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthViewModel>().currentUser?.uid;

    if (userId == null) {
      return const Center(
        child: Text('Tens de estar autenticado para ver os favoritos.'),
      );
    }

    final favoriteVm = context.read<FavoriteViewModel>();
    final eventVm = context.read<EventViewModel>();

    return StreamBuilder<List<Event>>(
      stream: favoriteVm.favoriteEventsStream(
        userId: userId,
        eventsStream: eventVm.eventsStream,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(
            child: Text('Nenhum evento favorito.'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
    );
  }
}