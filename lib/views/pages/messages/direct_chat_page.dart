import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/messages/message.dart';
import '../../../viewModels/messages/direct_message_viewModel.dart';
import '../../../viewModels/social/user_view_model.dart';

import '../../../services/messages/direct_chat_service.dart';

import '../../../data/models/social/user.dart';

class DirectChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const DirectChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<DirectChatPage> createState() => _DirectChatPageState();
}

class _DirectChatPageState extends State<DirectChatPage> {
  final TextEditingController _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  late final String chatId;

  @override
  void initState() {
    super.initState();

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    chatId = DirectChatService.generateChatId(
      currentUserId,
      widget.otherUserId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      context.read<DirectMessageViewModel>().markChatAsSeen(
        chatId: chatId,
        userId: currentUserId,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    await context.read<DirectMessageViewModel>().sendMessage(
      chatId: chatId,
      text: text,
    );

    _controller.clear();

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: context.read<DirectMessageViewModel>().getMessages(
                chatId,
              ),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    final msg = messages[index];

                    final isMe = msg.senderId == currentUserId;

                    return _MessageBubble(message: msg, isMe: isMe);
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,

                      textInputAction: TextInputAction.send,

                      onSubmitted: (_) => _sendMessage(),

                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Users?>(
      stream: context.read<UserViewModel>().userStream(message.senderId),

      builder: (context, snapshot) {
        final user = snapshot.data;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,

          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              if (!isMe) _Avatar(user: user),

              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 6,
                  ),

                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey.shade300,

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Text(
                    message.text,

                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                ),
              ),

              if (isMe) _Avatar(user: user),
            ],
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final Users? user;

  const _Avatar({this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),

      child: CircleAvatar(
        radius: 16,

        backgroundImage: user?.profilePictureUrl.isNotEmpty == true
            ? NetworkImage(user!.profilePictureUrl)
            : null,

        child: user?.profilePictureUrl.isEmpty ?? true
            ? const Icon(Icons.person, size: 16)
            : null,
      ),
    );
  }
}
