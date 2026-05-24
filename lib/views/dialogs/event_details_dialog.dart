import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/events/event_status.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/viewModels/authenthication/auth_viewModel.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/viewModels/events/favorite_event_viewModel.dart';
import 'package:t5/data/repositories/events/favorite_event_repository.dart';
import 'package:t5/theme/event_status_colors.dart';

class EventDetailsDialog extends StatelessWidget {
  final Event event;

  const EventDetailsDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthViewModel>().currentUser?.uid;
    final isCreator = userId == event.idCreator;
    final isLocked =
        event.status == EventStatus.occurring ||
        event.status == EventStatus.done;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Expanded(
            child: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (userId != null)
            StreamBuilder<bool>(
              stream: context.read<FavoriteRepository>().isEventFavorited(
                userId: userId,
                eventId: event.id,
              ),
              builder: (context, snapshot) {
                final isFavorited = snapshot.data ?? false;

                return PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) async {
                    switch (value) {
                      case 'favorite':
                        final vm = context.read<FavoriteViewModel>();
                        if (isFavorited) {
                          await vm.removeFavorite(
                            userId: userId,
                            eventId: event.id,
                          );
                        } else {
                          await vm.addFavorite(
                            userId: userId,
                            eventId: event.id,
                          );
                        }
                        break;
                      case 'edit':
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.editEvent,
                          arguments: {'event': event},
                        );
                        break;
                      case 'delete':
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Event?'),
                            content: const Text(
                              'Are you sure you want to delete this event? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          try {
                            await context.read<EventViewModel>().deleteEvent(event.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Event deleted successfully')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting event: $e')),
                              );
                            }
                          }
                        }
                        break;
                      case 'participants':
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.participants,
                          arguments: {
                            'eventId': event.id,
                            'creatorId': event.idCreator,
                          },
                        );
                        break;
                      case 'chat':
                        Navigator.pushNamed(
                          context,
                          AppRoutes.chat,
                          arguments: {
                            'eventId': event.id,
                            'title': event.title,
                          },
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'favorite',
                      child: Row(
                        children: [
                          Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isFavorited ? 'Remove Favorite' : 'Add Favorite',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    
                    if (isCreator && !isLocked)
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 10),
                            Text('Edit Event'),
                          ],
                        ),
                      ),
                      
                    if (isCreator && event.status == EventStatus.planning)
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Delete Event', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      
                    // A correção foi feita nesta linha:
                    if (isCreator && (!isLocked || event.status == EventStatus.planning))
                      const PopupMenuDivider(),
                      
                    const PopupMenuItem<String>(
                      value: 'participants',
                      child: Row(
                        children: [
                          Icon(Icons.people_outline),
                          SizedBox(width: 10),
                          Text('Participants'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'chat',
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline),
                          SizedBox(width: 10),
                          Text('Open Chat'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getEventStatusColor(event.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                event.status.text,
                style: TextStyle(
                  color: getEventStatusColor(event.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(event.description),
            const SizedBox(height: 12),
            Text('Location: ${event.city}, ${event.district}'),
            Text('Participants: ${event.currentUsers} / ${event.maxUsers}'),
            Text(
              'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(event.startDate)}',
            ),
          ],
        ),
      ),
      actions: [
        if (userId != null && !isCreator)
          StreamBuilder<bool>(
            stream: context.read<EventViewModel>().isUserInEvent(
              eventId: event.id,
              userId: userId,
            ),
            builder: (context, snapshot) {
              final isIn = snapshot.data ?? false;
              if (isLocked && !isIn) return const SizedBox.shrink();
              if (event.status != EventStatus.planning && isIn) {
                return const SizedBox.shrink();
              }
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isIn ? Colors.red : Colors.green,
                ),
                onPressed: () async {
                  final vm = context.read<EventViewModel>();
                  final success = isIn
                      ? await vm.leaveEvent(eventId: event.id, userId: userId)
                      : await vm.joinEvent(eventId: event.id, userId: userId);
                  if (success && context.mounted) Navigator.pop(context);
                },
                child: Text(isIn ? 'Leave Event' : 'Join Event'),
              );
            },
          ),
      ],
    );
  }
}
