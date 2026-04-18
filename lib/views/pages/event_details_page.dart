import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/viewModels/user_view_model.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedObjectives = List<int>.from(event.objectives)..sort();

    final authVm = context.watch<AuthViewModel>();
    final eventVm = context.watch<EventViewModel>();

    final userId = authVm.currentUser?.uid;
    final isCreator = userId == event.idCreator;
    final isFull = event.currentUsers >= event.maxUsers;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              event.description,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              "Objectives: ${sortedObjectives.join(', ')}",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "Country: ${event.country}",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "District: ${event.district}",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "City: ${event.city}",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "${event.currentUsers} / ${event.maxUsers} Participantes",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "${event.startDate} until ${event.endDate}",
              style: theme.textTheme.bodyMedium,
            ),
            StreamBuilder<Users?>(
              stream: context.read<UserViewModel>().userStream(event.idCreator),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Criado por...',
                    style: theme.textTheme.bodyMedium,
                  );
                }

                final creator = snapshot.data;

                return Text(
                  creator != null
                      ? 'Criado por ${creator.name}'
                      : 'Criado por utilizador desconhecido',
                  style: theme.textTheme.bodyMedium,
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                (userId == null || isCreator || isFull || eventVm.isLoading)
                    ? null
                    : () async {
                  final ok =
                  await context.read<EventViewModel>().joinEvent(
                    eventId: event.id,
                    userId: userId,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Entraste no evento com sucesso'
                            : (context
                            .read<EventViewModel>()
                            .errorMessage ??
                            'Erro ao entrar no evento'),
                      ),
                    ),
                  );
                },
                child: eventVm.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(
                  isCreator
                      ? 'És o criador deste evento'
                      : isFull
                      ? 'Evento cheio'
                      : 'Entrar no evento',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}