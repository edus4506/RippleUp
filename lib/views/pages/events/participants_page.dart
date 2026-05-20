import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/social/user.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/viewModels/events/participants_view_model.dart';

class ParticipantsPage extends StatefulWidget {
  final String eventId;
  final String creatorId;

  const ParticipantsPage({
    super.key,
    required this.eventId,
    required this.creatorId,
  });

  @override
  State<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  late Future<List<Users>> _participantsFuture;

  @override
  void initState() {
    super.initState();
    _participantsFuture = context
        .read<ParticipantsViewModel>()
        .getEventParticipants(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Participants'), centerTitle: true),
      body: FutureBuilder<List<Users>>(
        future: _participantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading participants: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _participantsFuture = context
                            .read<ParticipantsViewModel>()
                            .getEventParticipants(widget.eventId);
                      });
                    },
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          final participants = snapshot.data ?? [];

          if (participants.isEmpty) {
            return const Center(child: Text('No participants'));
          }

          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              final isCreator = participant.uid == widget.creatorId;

              return _ParticipantTile(
                participant: participant,
                isCreator: isCreator,
              );
            },
          );
        },
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final Users participant;
  final bool isCreator;

  const _ParticipantTile({required this.participant, required this.isCreator});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: participant.profilePictureUrl.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  participant.profilePictureUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person);
                  },
                ),
              )
            : const Icon(Icons.person),
      ),
      title: Row(
        children: [
          Expanded(child: Text(participant.name)),
          if (isCreator)
            Chip(
              label: const Text('Host'),
              backgroundColor: Colors.lightGreen.withValues(alpha: 0.3),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      subtitle: Text(
        participant.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.publicProfile,
          arguments: {'userId': participant.uid},
        );
      },
    );
  }
}
