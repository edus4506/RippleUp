import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:t5/views/widgets/top_bar_tabs/notification_dropdown.dart';
import 'package:t5/views/widgets/top_bar_tabs/swap_direct_messages_button.dart';
import 'package:t5/views/widgets/top_bar_tabs/top_bar.dart';

import '../../../data/models/messages/direct_chat_preview.dart';
import '../../../data/models/social/user.dart';
import '../../../data/models/messages/event_chat_preview.dart';

import '../../../data/repositories/messages/event_chat_repository.dart';
import '../../../data/repositories/messages/direct_message_repository.dart';

import '../../../viewModels/social/user_view_model.dart';

import 'direct_chat_page.dart';

import '../../../routes/app_routes.dart';

class DirectMessagesPage extends StatefulWidget {
  const DirectMessagesPage({super.key});

  @override
  State<DirectMessagesPage> createState() => _DirectMessagesPageState();
}

class _DirectMessagesPageState extends State<DirectMessagesPage> {
  bool showEventChats = false;

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: TopBar(
        leftWidget: NotificationDropdown(),

        title: "DM' s",

        rightWidget: SwapDMButton(
          showingEvents: showEventChats,

          onPressed: () {
            setState(() {
              showEventChats = !showEventChats;
            });
          },
        ),
      ),
      body: StreamBuilder<List<DirectChatPreview>>(
        stream: context.read<DirectMessageRepository>().getUserChats(
          currentUserId,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!;

          return StreamBuilder<List<EventChatPreview>>(
            stream: context.read<EventChatRepository>().getUserEventChats(
              currentUserId,
            ),
            builder: (context, eventSnapshot) {
              if (!eventSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = eventSnapshot.data!;

              if (events.isEmpty && chats.isEmpty) {
                return const Center(child: Text('No conversations yet'));
              }

              return ListView(
                padding: const EdgeInsets.all(12),

                children: showEventChats
                    ? [
                        ...events.map((event) {
                          final isMe = event.lastSenderId == currentUserId;

                          final isUnread =
                              !event.lastSeenBy.contains(currentUserId) &&
                              event.lastSenderId != currentUserId;

                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<EventChatRepository>()
                                  .markEventChatAsSeen(
                                    eventId: event.eventId,
                                    userId: currentUserId,
                                  );
                              Navigator.pushNamed(
                                context,
                                AppRoutes.chat,

                                arguments: {
                                  'eventId': event.eventId,

                                  'title': event.title,
                                },
                              );
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),

                              width: double.infinity,

                              padding: const EdgeInsets.all(14),

                              margin: const EdgeInsets.only(bottom: 12),

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(18),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(10),

                                    blurRadius: 8,

                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),

                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,

                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F3E4),

                                      shape: BoxShape.circle,
                                    ),

                                    child: const Icon(
                                      Icons.groups,

                                      color: Color(0xFF4A693D),

                                      size: 28,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          event.title,

                                          style: const TextStyle(
                                            fontSize: 18,

                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          '${isMe ? 'Sent' : 'Received'} • ${formatRelativeTime(event.lastMessageAt)}',

                                          style: TextStyle(
                                            color: Colors.black54,

                                            fontWeight: isUnread
                                                ? FontWeight.w700
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (isUnread)
                                    Container(
                                      width: 12,
                                      height: 12,

                                      decoration: const BoxDecoration(
                                        color: Colors.green,

                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ]
                    : [
                        ...chats.map((chat) {
                          final otherUserId = chat.participants.firstWhere(
                            (id) => id != currentUserId,
                          );

                          return StreamBuilder<Users?>(
                            stream: context.read<UserViewModel>().userStream(
                              otherUserId,
                            ),

                            builder: (context, userSnapshot) {
                              final user = userSnapshot.data;

                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.all(24),

                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (user == null) {
                                return const SizedBox();
                              }

                              return _HoverChatCard(
                                chat: chat,

                                user: user,

                                currentUserId: currentUserId,

                                otherUserId: otherUserId,
                              );
                            },
                          );
                        }),
                      ],
              );
            },
          );
        },
      ),
    );
  }
}

String formatRelativeTime(DateTime? time) {
  if (time == null) {
    return 'now';
  }

  final difference = DateTime.now().difference(time);

  if (difference.inSeconds < 60) {
    return 'now';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }

  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }

  return DateFormat('dd/MM/yyyy').format(time);
}

class _HoverChatCard extends StatefulWidget {
  final DirectChatPreview chat;

  final Users user;

  final String currentUserId;

  final String otherUserId;

  const _HoverChatCard({
    required this.chat,
    required this.user,
    required this.currentUserId,
    required this.otherUserId,
  });

  @override
  State<_HoverChatCard> createState() => _HoverChatCardState();
}

class _HoverChatCardState extends State<_HoverChatCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMe = widget.chat.lastSenderId == widget.currentUserId;

    final isUnread =
        !widget.chat.lastSeenBy.contains(widget.currentUserId) &&
        widget.chat.lastSenderId != widget.currentUserId;

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },

      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DirectChatPage(
                otherUserId: widget.otherUserId,

                otherUserName: widget.user.name,
              ),
            ),
          );
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          width: double.infinity,

          padding: const EdgeInsets.all(14),

          margin: const EdgeInsets.only(bottom: 12),

          decoration: BoxDecoration(
            color: isHovered ? const Color(0xFFF2F2F2) : Colors.white,

            borderRadius: BorderRadius.circular(18),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isHovered ? 18 : 10),

                blurRadius: isHovered ? 12 : 8,

                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Row(
            children: [
              CircleAvatar(
                radius: 28,

                backgroundImage: widget.user.profilePictureUrl.isNotEmpty
                    ? NetworkImage(widget.user.profilePictureUrl)
                    : null,

                child: widget.user.profilePictureUrl.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      widget.user.name,

                      style: const TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${isMe ? 'Sent' : 'Received'} • ${formatRelativeTime(widget.chat.lastMessageAt)}',

                      style: TextStyle(
                        color: Colors.black54,

                        fontWeight: isUnread
                            ? FontWeight.w900
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnread)
                Container(
                  width: 12,
                  height: 12,

                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
