import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/notification.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/notification_viewModel.dart';

class NotificationDropdown extends StatefulWidget {
  const NotificationDropdown({super.key});

  @override
  State<NotificationDropdown> createState() => _NotificationDropdownState();
}

class _NotificationDropdownState extends State<NotificationDropdown> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<AuthViewModel>().currentUser;

      if (currentUser == null) {
        debugPrint('Current user is null');
        return;
      }

      context.read<AppNotificationViewModel>().checkUpcomingEvents(
        currentUser.uid,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthViewModel>().currentUser;

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<AppNotification>>(
      stream: context.watch<AppNotificationViewModel>().getNotifications(
        currentUser.uid,
      ),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Icon(Icons.notifications);
        }

        final notifications = snapshot.data ?? [];

        final vm = context.read<AppNotificationViewModel>();

        final sortedNotifications = vm.sortNotifications(notifications);

        final unseen = vm.getUnseenNotifications(sortedNotifications);

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

            final items =
              unseen.map((notification) {
                return PopupMenuItem<AppNotification>(
                  value: notification,

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 3),
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: notification.seen
                          ? Colors.white
                          : const Color(0xFFF3FAF4),

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(
                        color: notification.seen
                            ? Colors.grey.shade300
                            : Colors.green.shade200,
                      ),
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Container(
                          width: 42,
                          height: 42,

                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F5EA),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Icon(
                            vm.getNotificationIcon(notification.type),

                            color: Colors.green.shade700,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,

                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),

                                  Text(
                                    '${notification.createdAt.hour.toString().padLeft(2, '0')}:'
                                    '${notification.createdAt.minute.toString().padLeft(2, '0')}',

                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Text(
                                notification.body,

                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Checkbox(
                          value: notification.seen,

                          activeColor: Colors.green,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),

                          onChanged: (_) async {
                            final navigator =
                                Navigator.of(context);

                            await context
                                .read<AppNotificationViewModel>()
                                .markAsSeen(
                                  notification,
                                  currentUser.uid,
                                );

                            if (!mounted) return;

                            navigator.pop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList();

          items.add(
            PopupMenuItem(
              enabled: false,

              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),

                    borderRadius: BorderRadius.circular(14),

                    border: Border.all(
                      color: Colors.green.shade700,
                      width: 1.2,
                    ),
                  ),

                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),

                    onPressed: () async {
                      Navigator.pop(context);

                      await context
                          .read<AppNotificationViewModel>()
                          .clearNotifications(
                            currentUser.uid,
                          );
                    },

                    icon: const Icon(
                      Icons.delete,
                      color: Colors.black,
                      size: 22,
                    ),

                    label: const Text(
                      'Clear notifications',

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          return items;
          },
        );
      },
    );
  }
}
