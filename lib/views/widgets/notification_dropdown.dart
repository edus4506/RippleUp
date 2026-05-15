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

class _NotificationDropdownState extends State<NotificationDropdown> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context
          .read<AppNotificationViewModel>()
          .checkUpcomingEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppNotification>>(
      stream: context
          .watch<AppNotificationViewModel>()
          .getNotifications(),

      builder: (context, snapshot) {

        final notifications = snapshot.data ?? [];

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
                  children: [

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            notification.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(notification.body),
                        ],
                      ),
                    ),

                    Checkbox(
                      value: notification.seen,
                      onChanged: (_) async {
                        final navigator = Navigator.of(context);
                        await context
                            .read<AppNotificationViewModel>()
                            .markAsSeen(notification);

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