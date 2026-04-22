import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/viewModels/favorite_view_model.dart';
import 'package:t5/viewModels/user_view_model.dart';

class EventDetailsDialog extends StatelessWidget {
  final Event event;

  const EventDetailsDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthViewModel>().currentUser?.uid;
    final eventVm = context.read<EventViewModel>();

    final sortedObjectives = List<int>.from(event.objectives)..sort();

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
              _Header(event: event, userId: userId),

              const SizedBox(height: 10),

              _Content(event: event, sortedObjectives: sortedObjectives),

              const SizedBox(height: 10),

              _Actions(
                event: event,
                userId: userId,
                eventVm: eventVm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Event event;
  final String? userId;

  const _Header({required this.event, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            event.title,
            style: theme.textTheme.titleMedium,
          ),
        ),

        if (userId != null)
          StreamBuilder<bool>(
            stream: context.read<FavoriteViewModel>().isEventFavorited(
                  userId: userId!,
                  eventId: event.id,
                ),
            builder: (context, snapshot) {
              final isFavorited = snapshot.data ?? false;

              return IconButton(
                icon: Icon(
                  isFavorited
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorited ? Colors.red : null,
                ),
                onPressed: () async {
                  final vm = context.read<FavoriteViewModel>();

                  if (isFavorited) {
                    await vm.removeFavorite(
                      userId: userId!,
                      eventId: event.id,
                    );
                  } else {
                    await vm.addFavorite(
                      userId: userId!,
                      eventId: event.id,
                    );
                  }
                },
              );
            },
          ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final Event event;
  final List<int> sortedObjectives;

  const _Content({
    required this.event,
    required this.sortedObjectives,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                final creator = snapshot.data;

                return Text(
                  creator != null
                      ? 'Created by ${creator.name}'
                      : 'Created by unknown user'
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final Event event;
  final String? userId;
  final EventViewModel eventVm;

  const _Actions({
    required this.event,
    required this.userId,
    required this.eventVm,
  });

  @override
  Widget build(BuildContext context) {
    final isCreator = userId == event.idCreator;
    final isFull = event.currentUsers >= event.maxUsers;

    return StreamBuilder<bool>(
      stream: (userId != null)
          ? eventVm.isUserInEvent(
              eventId: event.id,
              userId: userId!,
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
                    : () => _handleJoinLeave(
                          context,
                          isParticipant,
                        ),
                child: eventVm.isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        isCreator
                            ? 'You are the creator'
                            : isParticipant
                                ? 'Leave'
                                : isFull
                                    ? 'Full'
                                    : 'Join'
                      ),
              ),
            ),

            if (isCreator)
              _DeleteButton(event: event),
          ],
        );
      },
    );
  }

  Future<void> _handleJoinLeave(
    BuildContext context,
    bool isParticipant,
  ) async {
    final vm = context.read<EventViewModel>();

    final ok = isParticipant
        ? await vm.leaveEvent(
            eventId: event.id,
            userId: userId!,
          )
        : await vm.joinEvent(
            eventId: event.id,
            userId: userId!,
          );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
            ? (isParticipant
                ? 'You left the event'
                : 'You joined the event')
            : (vm.errorMessage ?? 'Error')
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final Event event;

  const _DeleteButton({required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  title: const Text('Delete event'),
                  content: const Text('Are you sure?'),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      child: const Text('Delete'),
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

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'Event deleted' : 'Error'
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ),
      ],
    );
  }
}