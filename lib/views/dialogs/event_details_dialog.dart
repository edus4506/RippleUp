import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/event_status.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/viewModels/favorite_view_model.dart';
import 'package:t5/viewModels/user_view_model.dart';
import 'package:t5/theme/event_status_colors.dart';

class EventDetailsDialog extends StatelessWidget {
  final Event event;

  const EventDetailsDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthViewModel>().currentUser?.uid;
    final isLocked =
        event.status == EventStatus.occurring ||
        event.status == EventStatus.done;

    return AlertDialog(
      title: Text(event.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Creator info
            if (userId != null)
              StreamBuilder(
                stream: context.read<UserViewModel>().userStream(
                  event.idCreator,
                ),
                builder: (context, snapshot) {
                  final creatorName = snapshot.data?.name ?? '...';
                  return Text('Created by: $creatorName');
                },
              ),

            const SizedBox(height: 8),

            // Status badge
            Row(
              children: [
                const Text('Status: '),
                Text(
                  event.status.text,
                  style: TextStyle(
                    color: getEventStatusColor(event.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(event.description),

            const SizedBox(height: 8),

            Text('${event.city}, ${event.district}, ${event.country}'),

            const SizedBox(height: 4),

            Text('Participants: ${event.currentUsers}/${event.maxUsers}'),

            const SizedBox(height: 4),

            Text(
              'Start: ${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
            ),
            Text(
              'End: ${event.endDate.day}/${event.endDate.month}/${event.endDate.year}',
            ),

            const SizedBox(height: 8),

            // Favorite button
            if (userId != null)
              StreamBuilder<bool>(
                stream: context.read<FavoriteViewModel>().isEventFavorited(
                  userId: userId,
                  eventId: event.id,
                ),
                builder: (context, snapshot) {
                  final isFav = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      final favVm = context.read<FavoriteViewModel>();
                      if (isFav) {
                        favVm.removeFavorite(userId: userId, eventId: event.id);
                      } else {
                        favVm.addFavorite(userId: userId, eventId: event.id);
                      }
                    },
                  );
                },
              ),
          ],
        ),
      ),
      actions: [_Actions(event: event, userId: userId, isLocked: isLocked)],
    );
  }
}

class _Actions extends StatelessWidget {
  final Event event;
  final String? userId;
  final bool isLocked;

  const _Actions({
    required this.event,
    required this.userId,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      );
    }

    final isCreator = event.idCreator == userId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Join / Leave — only for non-creators
        if (!isCreator)
          StreamBuilder<bool>(
            stream: context.read<EventViewModel>().isUserInEvent(
              eventId: event.id,
              userId: userId!,
            ),
            builder: (context, snapshot) {
              final isIn = snapshot.data ?? false;

              return ElevatedButton(
                onPressed: isLocked
                    ? null
                    : () async {
                        final vm = context.read<EventViewModel>();
                        bool success;

                        if (isIn) {
                          success = await vm.leaveEvent(
                            eventId: event.id,
                            userId: userId!,
                          );
                        } else {
                          success = await vm.joinEvent(
                            eventId: event.id,
                            userId: userId!,
                          );
                        }

                        if (!context.mounted) return;

                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                vm.errorMessage ?? 'Something went wrong',
                              ),
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                child: Text(isIn ? 'Leave' : 'Join'),
              );
            },
          ),

        // Delete — only for creator
        if (isCreator)
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: isLocked
                ? null
                : () async {
                    final vm = context.read<EventViewModel>();
                    final success = await vm.deleteEvent(event.id);

                    if (!context.mounted) return;

                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            vm.errorMessage ?? 'Something went wrong',
                          ),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
            child: const Text('Delete'),
          ),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
