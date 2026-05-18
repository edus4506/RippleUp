import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/direct_chat_preview.dart';
import '../../data/models/user.dart';

import '../../data/repositories/direct_message_repository.dart';

import '../../viewModels/user_view_model.dart';

import 'direct_chat_page.dart';

class DirectMessagesPage extends StatelessWidget {
  const DirectMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),

      body: StreamBuilder<List<DirectChatPreview>>(
        stream: context
            .read<DirectMessageRepository>()
            .getUserChats(currentUserId),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final chats = snapshot.data!;

          if (chats.isEmpty) {
            return const Center(
              child: Text('No conversations yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),

            itemCount: chats.length,

            itemBuilder: (context, index) {
              final chat = chats[index];

              final otherUserId = chat.participants
                  .firstWhere(
                    (id) => id != currentUserId,
                  );

              return StreamBuilder<Users?>(
                stream: context
                    .read<UserViewModel>()
                    .userStream(otherUserId),

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
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'User not found: $otherUserId',
                      ),
                    );
                  }

                  final isMe =
                      chat.lastSenderId ==
                      currentUserId;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DirectChatPage(
                                otherUserId:
                                    otherUserId,

                                otherUserName:
                                    user.name,
                              ),
                        ),
                      );
                    },

                    child: Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(14),

                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(18),

                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withAlpha(
                                  10,
                                ),

                            blurRadius: 8,

                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,

                            backgroundImage:
                                user.profilePictureUrl
                                        .isNotEmpty
                                    ? NetworkImage(
                                        user
                                            .profilePictureUrl,
                                      )
                                    : null,

                            child:
                                user.profilePictureUrl
                                        .isEmpty
                                    ? const Icon(
                                        Icons.person,
                                      )
                                    : null,
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                Text(
                                  user.name,

                                  style:
                                      const TextStyle(
                                        fontSize: 18,

                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  isMe
                                      ? 'You: ${chat.lastMessage}'
                                      : chat.lastMessage,

                                  maxLines: 1,

                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      const TextStyle(
                                        color:
                                            Colors
                                                .black54,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}