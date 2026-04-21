import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/favorite_userEvent.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/viewModels/favorite_view_model.dart';
import 'package:t5/views/dialogs/event_details_dialog.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  void _openEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (_) => EventDetailsDialog(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthViewModel>().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        //botao voltar provisorio
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: userId == null
          ? const Center(
              child: Text('Tens de estar autenticado para ver os favoritos.'),
            )
          : StreamBuilder<List<Favorite>>(
              stream: context
                  .read<FavoriteViewModel>()
                  .userFavoritesStream(userId),
              builder: (context, favSnapshot) {
                if (favSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final favorites = favSnapshot.data ?? [];

                if (favorites.isEmpty) {
                  return const Center(
                      child: Text('Nenhum evento favorito.'));
                }

                return StreamBuilder<List<Event>>(
                  stream:
                      context.read<EventViewModel>().eventsStream,
                  builder: (context, eventSnapshot) {
                    if (eventSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final allEvents = eventSnapshot.data ?? [];
                    final favEventIds =
                        favorites.map((f) => f.idEvent).toSet();

                    final favEvents = allEvents
                        .where((e) => favEventIds.contains(e.id))
                        .toList();

                    if (favEvents.isEmpty) {
                      return const Center(
                          child: Text('Nenhum evento favorito.'));
                    }

                    return ListView.builder(
                      itemCount: favEvents.length,
                      itemBuilder: (context, index) {
                        final event = favEvents[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            onTap: () =>
                                _openEventDetails(context, event),
                            title: Text(event.title),
                            subtitle: Text(
                                '${event.city}, ${event.district} — ${event.eventStatus}'),
                            trailing: Text(
                                '${event.currentUsers}/${event.maxUsers}'),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}