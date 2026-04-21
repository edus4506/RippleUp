import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/favorite_userEvent.dart';
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

    return StreamBuilder<List<Favorite>>(
      stream:
          context.read<FavoriteViewModel>().userFavoritesStream(userId),
      builder: (context, favSnapshot) {
        if (favSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final favorites = favSnapshot.data ?? [];

        if (favorites.isEmpty) {
          return const Center(
            child: Text('Nenhum evento favorito.'),
          );
        }

        return StreamBuilder<List<Event>>(
          stream: context.read<EventViewModel>().eventsStream,
          builder: (context, eventSnapshot) {
            if (eventSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allEvents = eventSnapshot.data ?? [];
            final favEventIds =
                favorites.map((f) => f.idEvent).toSet();

            final favEvents = allEvents
                .where((e) => favEventIds.contains(e.id))
                .toList();

            if (favEvents.isEmpty) {
              return const Center(
                child: Text('Nenhum evento favorito.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favEvents.length,
              itemBuilder: (context, index) {
                final event = favEvents[index];

                return EventCard(
                  event: event,
                  onTap: () => _openEventDetails(context, event),
                );
              },
            );
          },
        );
      },
    );
  }
}