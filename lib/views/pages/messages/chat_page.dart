import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:t5/viewModels/messages/message_viewModel.dart';
import 'package:t5/routes/app_routes.dart';

import '../../../viewModels/social/user_view_model.dart';
import '../../../data/models/messages/message.dart';
import '../../../data/models/social/user.dart';
import '../../../data/repositories/social/participation_repository.dart';

class ChatPage extends StatefulWidget {
  final String eventId;
  final String title;

  const ChatPage({super.key, required this.eventId, required this.title});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    await context.read<MessageViewModel>().sendMessage(widget.eventId, text);

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

    final participationRepo = context.read<ParticipationRepository>();

    return Scaffold(
      appBar: AppBar(title: Text("${widget.title} Chat")),

      body: FutureBuilder<bool>(
        future: participationRepo.hasUserParticipated(
          currentUserId!,
          widget.eventId,
        ),

        builder: (context, participationSnapshot) {
          if (!participationSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final canSend = participationSnapshot.data!;

          return Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: context.read<MessageViewModel>().getMessages(
                    widget.eventId,
                  ),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!;

                    if (messages.isEmpty) {
                      return const Center(child: Text("No messages yet"));
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),

                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,

                          enabled: canSend,

                          textInputAction: TextInputAction.send,

                          onSubmitted: canSend ? (_) => _sendMessage() : null,

                          decoration: InputDecoration(
                            hintText: canSend
                                ? "Type a message..."
                                : "You left this event",

                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      IconButton(
                        icon: const Icon(Icons.send),

                        onPressed: canSend ? _sendMessage : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  void _goToProfile(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.publicProfile,
      arguments: {'userId': message.senderId},
    );
  }

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
              if (!isMe)
                GestureDetector(
                  onTap: () => _goToProfile(context),
                  child: _Avatar(user: user),
                ),

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe)
                        GestureDetector(
                          onTap: () => _goToProfile(context),
                          child: Text(
                            user?.name ?? "...",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      Text(
                        message.text,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
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
