import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/viewModels/user_view_model.dart';

class EventDetailsDialog extends StatelessWidget {
  final Event event;

  const EventDetailsDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedObjectives = List<int>.from(event.objectives)..sort();

    final authVm = context.watch<AuthViewModel>();
    final eventVm = context.read<EventViewModel>();

    final userId = authVm.currentUser?.uid;
    final isCreator = userId == event.idCreator;
    final isFull = event.currentUsers >= event.maxUsers;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                event.title,
                style: theme.textTheme.titleMedium,
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.description),
                      const SizedBox(height: 10),

                      Text("Objectives: ${sortedObjectives.join(', ')}"),
                      Text("Country: ${event.country}"),
                      Text("District: ${event.district}"),
                      Text("City: ${event.city}"),
                      Text("${event.currentUsers} / ${event.maxUsers}"),
                      Text("${event.startDate} until ${event.endDate}"),

                      const SizedBox(height: 10),

                      StreamBuilder<Users?>(
                        stream: context
                            .read<UserViewModel>()
                            .userStream(event.idCreator),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Criado por...');
                          }

                          final creator = snapshot.data;

                          return Text(
                            creator != null
                                ? 'Criado por ${creator.name}'
                                : 'Criado por utilizador desconhecido',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              StreamBuilder<bool>(
                stream: (userId != null)
                    ? eventVm.isUserInEvent(
                        eventId: event.id,
                        userId: userId,
                      )
                    : null,
                builder: (context, snapshot) {
                  final isParticipant = snapshot.data ?? false;

                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (userId == null ||
                                  isCreator ||
                                  eventVm.isLoading ||
                                  (!isParticipant && isFull))
                              ? null
                              : () async {
                                  final vm =
                                      context.read<EventViewModel>();

                                  final ok = isParticipant
                                      ? await vm.leaveEvent(
                                          eventId: event.id,
                                          userId: userId,
                                        )
                                      : await vm.joinEvent(
                                          eventId: event.id,
                                          userId: userId,
                                        );

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ok
                                            ? (isParticipant
                                                ? 'Saíste do evento'
                                                : 'Entraste no evento')
                                            : (vm.errorMessage ?? 'Erro'),
                                      ),
                                    ),
                                  );
                                },
                          child: eventVm.isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                  isCreator
                                      ? 'És o criador'
                                      : isParticipant
                                          ? 'Sair'
                                          : isFull
                                              ? 'Cheio'
                                              : 'Entrar',
                                ),
                        ),
                      ),

                      if (isCreator) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title:
                                      const Text('Eliminar evento'),
                                  content: const Text(
                                      'Tens a certeza?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child:
                                          const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Apagar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              final ok = await context
                                  .read<EventViewModel>()
                                  .deleteEvent(event.id);

                              if (!context.mounted) return;

                              if (ok) Navigator.pop(context);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Evento eliminado'
                                        : 'Erro',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Eliminar'),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}