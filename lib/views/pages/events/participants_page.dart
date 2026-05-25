import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: _ParticipantsTopBar(onBack: () => Navigator.of(context).pop()),
      body: FutureBuilder<List<Users>>(
        future: _participantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading participants',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _participantsFuture = context
                            .read<ParticipantsViewModel>()
                            .getEventParticipants(widget.eventId);
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          final participants = snapshot.data ?? [];

          if (participants.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group_off_rounded,
                    size: 56,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No participants yet.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

// ── Top Bar ──────────────────────────────────────────────────

class _ParticipantsTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onBack;

  const _ParticipantsTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final totalHeight = 70 + topPadding;

    return SizedBox(
      height: totalHeight,
      child: Container(
        width: double.infinity,
        height: totalHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(34),
            bottomRight: Radius.circular(34),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Stack(
            children: [
              // Ícones decorativos
              Positioned(
                top: -7,
                left: 65,
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(Icons.eco_rounded, size: 80, color: Colors.white),
                ),
              ),
              Positioned(
                top: -7,
                right: 65,
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(Icons.eco_rounded, size: 80, color: Colors.white),
                ),
              ),

              // Botão voltar
              Positioned(
                top: 0,
                bottom: 0,
                left: 20,
                child: _CircleButton(
                  onTap: onBack,
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),

              // Título central
              Align(
                alignment: Alignment.center,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 219,
                    maxWidth: 221,
                  ),
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7EF),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0, -2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 2),
                            child: Transform.rotate(
                              angle: -1.57,
                              child: Icon(
                                Icons.grass_rounded,
                                size: 22,
                                color: Colors.green.shade300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'People',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 36,
                              color: const Color(0xFF2E7D32),
                              height: 1,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Transform.translate(
                            offset: const Offset(0, 2),
                            child: Transform.rotate(
                              angle: 1.57,
                              child: Icon(
                                Icons.grass_rounded,
                                size: 22,
                                color: Colors.green.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70 + 44);
}

// ── Botão circular com hover ──────────────────────────────────

class _CircleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _CircleButton({required this.child, required this.onTap});

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isHovered
                ? Colors.white.withOpacity(0.30)
                : Colors.white.withOpacity(0.14),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

// ── Tile de participante ──────────────────────────────────────

class _ParticipantTile extends StatelessWidget {
  final Users participant;
  final bool isCreator;

  const _ParticipantTile({required this.participant, required this.isCreator});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8F0E9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.publicProfile,
            arguments: {'userId': participant.uid},
          );
        },
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCreator
                  ? Colors.green.shade300
                  : const Color(0xFFE0E0E0),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: participant.profilePictureUrl.isNotEmpty
                ? Image.network(
                    participant.profilePictureUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, color: Colors.grey),
                  )
                : const Icon(Icons.person, color: Colors.grey),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                participant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (isCreator)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade700, width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      size: 15,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Host',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            participant.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
