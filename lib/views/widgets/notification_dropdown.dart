import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/notification.dart';
import 'package:t5/viewModels/notification_viewModel.dart';


class NotificationDropdown extends StatefulWidget {
  const NotificationDropdown({super.key});

  @override
  State<NotificationDropdown> createState() =>
      _NotificationDropdownState();
}

class _NotificationDropdownState
    extends State<NotificationDropdown> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context
          .read<AppNotificationViewModel>()
          .checkUpcomingEvents();
    });
  }

  IconData getNotificationIcon(String? type) {
    switch (type) {

      case 'new_event':
        return Icons.event_available;

      case 'upcoming_event':
        return Icons.access_time;

      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<AppNotification>>(
      stream: context
          .watch<AppNotificationViewModel>()
          .getNotifications(),

      builder: (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return const Icon(Icons.notifications);
        }

        final notifications = snapshot.data ?? [];
        

        // newest first
        notifications.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );

        final unseen =
            notifications.where((n) => !n.seen).toList();

        return PopupMenuButton<AppNotification>(
          icon: Badge(
            label: Text(unseen.length.toString()),
            isLabelVisible: unseen.isNotEmpty,
            child: const Icon(Icons.notifications),
          ),

          itemBuilder: (context) {

            if (unseen.isEmpty) {

              return [
                const PopupMenuItem(
                  enabled: false,
                  child: Text('No notifications'),
                ),
              ];
            }

            return unseen.map((notification) {

              return PopupMenuItem<AppNotification>(
                value: notification,

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Padding(
                      padding:
                          const EdgeInsets.only(
                        right: 12,
                        top: 2,
                      ),

                      child: Icon(
                        getNotificationIcon(
                          notification.type,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            notification.title,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(notification.body),

                          const SizedBox(height: 6),

                          Text(
                            '${notification.createdAt.year.toString().padLeft(4, '0')}-'
                            '${notification.createdAt.month.toString().padLeft(2, '0')}-'
                            '${notification.createdAt.day.toString().padLeft(2, '0')} '
                            '${notification.createdAt.hour.toString().padLeft(2, '0')}:'
                            '${notification.createdAt.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),

                    Checkbox(
                      value: notification.seen,

                      onChanged: (_) async {

                        final navigator =
                            Navigator.of(context);

                        await context
                            .read<
                                AppNotificationViewModel>()
                            .markAsSeen(
                              notification,
                            );

                        navigator.pop();
                      },
                    ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}