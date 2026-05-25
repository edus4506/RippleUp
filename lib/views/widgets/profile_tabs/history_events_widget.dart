import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/events/event_status.dart';
import 'package:t5/data/models/social/participation.dart';
import 'package:t5/data/repositories/social/participation_repository.dart';
import 'package:t5/viewModels/authentication/auth_viewModel.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/views/dialogs/event_details_dialog.dart';
import '../event_card.dart';

class HistoryEventsWidget extends StatelessWidget {
  const HistoryEventsWidget({super.key});

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
        child: Text('You must be logged in to view your history.'),
      );
    }

    final participationRepo = context.read<ParticipationRepository>();
    final eventVm = context.watch<EventViewModel>();

    return StreamBuilder<List<Participation>>(
      stream: participationRepo.listenToUserParticipations(userId),
      builder: (context, partSnap) {
        if (partSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final participations = partSnap.data ?? [];
        final joinedIds = participations.map((p) => p.idEvent).toSet();

        if (joinedIds.isEmpty) {
          return const Center(
            child: Text('You have not participated in any events yet.'),
          );
        }

        return StreamBuilder<List<Event>>(
          stream: eventVm.eventsStream,
          builder: (context, eventSnap) {
            if (eventSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allEvents = eventSnap.data ?? [];

            final doneEvents =
                allEvents
                    .where(
                      (e) =>
                          joinedIds.contains(e.id) &&
                          e.status == EventStatus.done,
                    )
                    .toList()
                  ..sort(
                    (a, b) => b.startDate.compareTo(a.startDate),
                  ); // mais recente primeiro

            if (doneEvents.isEmpty) {
              return const Center(
                child: Text('You have not participated in any events yet.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doneEvents.length,
              itemBuilder: (context, index) {
                final event = doneEvents[index];
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
