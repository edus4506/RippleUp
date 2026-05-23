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

  static const _green = Color(0xFF0A7A3E);
  static const _greenLight = Color(0xFFF1F8F3);

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
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: _green,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _greenLight,
              backgroundImage: const AssetImage('assets/rippleup_logo.png'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _green,
                  ),
                ),
                const Text(
                  'Event chat',
                  style: TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ],
        ),
      ),
      body: FutureBuilder<bool>(
        future: participationRepo.hasUserParticipated(
          currentUserId!,
          widget.eventId,
        ),
        builder: (context, participationSnapshot) {
          if (!participationSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _green),
            );
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
                      return const Center(
                        child: CircularProgressIndicator(color: _green),
                      );
                    }

                    final messages = snapshot.data!;

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: _greenLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: _green,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No messages yet',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Be the first to say something!',
                              style: TextStyle(
                                color: Colors.black26,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == currentUserId;
                        final showDate =
                            index == 0 ||
                            !_sameDay(
                              messages[index - 1].createdAt,
                              msg.createdAt,
                            );
                        return Column(
                          children: [
                            if (showDate) _DateChip(date: msg.createdAt),
                            _MessageBubble(message: msg, isMe: isMe),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              _ChatInputBar(
                controller: _controller,
                canSend: canSend,
                onSend: _sendMessage,
              ),
            ],
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _DateChip extends StatelessWidget {
  final DateTime? date;
  const _DateChip({this.date});

  @override
  Widget build(BuildContext context) {
    final label = date != null
        ? '${date!.day}/${date!.month}/${date!.year}'
        : 'Today';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.controller,
    required this.canSend,
    required this.onSend,
  });

  static const _green = Color(0xFF0A7A3E);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            if (!canSend)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.block_outlined,
                  color: Colors.black26,
                  size: 20,
                ),
              ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: canSend,
                textInputAction: TextInputAction.send,
                onSubmitted: canSend ? (_) => onSend() : null,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: canSend
                      ? 'Type a message...'
                      : 'You left this event',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: canSend
                      ? const Color(0xFFF1F8F3)
                      : const Color(0xFFF3F3F3),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: _green, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: canSend ? _green : Colors.black12,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.send_rounded,
                  size: 18,
                  color: canSend ? Colors.white : Colors.black26,
                ),
                onPressed: canSend ? onSend : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  static const _green = Color(0xFF0A7A3E);

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

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                GestureDetector(
                  onTap: () => _goToProfile(context),
                  child: _Avatar(user: user, isMe: false),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 2),
                        child: GestureDetector(
                          onTap: () => _goToProfile(context),
                          child: Text(
                            user?.name ?? '...',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? _green : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMe ? 18 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 18),
                        ),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: isMe ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                    //if (message.createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                      child: Text(
                        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 6),
                _Avatar(user: user, isMe: true),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final Users? user;
  final bool isMe;

  const _Avatar({this.user, required this.isMe});

  static const _green = Color(0xFF0A7A3E);

  @override
  Widget build(BuildContext context) {
    final hasPhoto = user?.profilePictureUrl.isNotEmpty == true;
    return CircleAvatar(
      radius: 15,
      backgroundColor: isMe ? _green : const Color(0xFFE8F0FE),
      backgroundImage: hasPhoto ? NetworkImage(user!.profilePictureUrl) : null,
      child: hasPhoto
          ? null
          : Icon(
              Icons.person,
              size: 15,
              color: isMe ? Colors.white : const Color(0xFF1a73e8),
            ),
    );
  }
}
