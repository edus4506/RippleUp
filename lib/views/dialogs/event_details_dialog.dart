import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/events/event_status.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/viewModels/authenthication/auth_viewModel.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/viewModels/events/favorite_event_viewModel.dart';
import 'package:t5/data/repositories/events/favorite_event_repository.dart';
import 'package:t5/theme/event_status_colors.dart';
import 'package:t5/theme/palette.dart';

class EventDetailsDialog extends StatelessWidget {
  final Event event;

  const EventDetailsDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthViewModel>().currentUser?.uid;
    final isCreator = userId == event.idCreator;
    final isLocked =
        event.status == EventStatus.occurring ||
        event.status == EventStatus.done;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.hardEdge,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Badge à esquerda
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusBadge(status: event.status),
                ),

                // Título centrado com folhinhas
                Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
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
                            size: 18,
                            color: Colors.green.shade300,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.title,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 26,
                            color: const Color(0xFF2E7D32),
                            height: 1,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Transform.translate(
                        offset: const Offset(0, 2),
                        child: Transform.rotate(
                          angle: 1.57,
                          child: Icon(
                            Icons.grass_rounded,
                            size: 18,
                            color: Colors.green.shade300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: -10,
                  right: 40,
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Menu à direita
                if (userId != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _MenuButton(
                      event: event,
                      userId: userId,
                      isCreator: isCreator,
                      isLocked: isLocked,
                    ),
                  ),
              ],
            ),
          ),

          // ── Corpo ──
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrição
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Palette.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Localização
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: '${event.city}, ${event.district}',
                  ),
                  const SizedBox(height: 12),

                  // Data
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: DateFormat(
                      'dd/MM/yyyy · HH:mm',
                    ).format(event.startDate),
                  ),
                  const SizedBox(height: 12),

                  // Participantes
                  _ParticipantsRow(event: event),

                  // Imagens
                  if (event.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(color: Palette.border),
                    const SizedBox(height: 14),
                    _ImageGallery(imageUrls: event.imageUrls),
                  ],
                ],
              ),
            ),
          ),

          // ── Botão Join/Leave ──
          if (userId != null && !isCreator)
            _JoinLeaveButton(event: event, userId: userId, isLocked: isLocked),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final EventStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = getEventStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 5),
          Text(
            status.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Menu Button
// ─────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  final Event event;
  final String userId;
  final bool isCreator;
  final bool isLocked;

  const _MenuButton({
    required this.event,
    required this.userId,
    required this.isCreator,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: context.read<FavoriteRepository>().isEventFavorited(
        userId: userId,
        eventId: event.id,
      ),
      builder: (context, snapshot) {
        final isFavorited = snapshot.data ?? false;

        return PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) async {
            switch (value) {
              case 'favorite':
                final vm = context.read<FavoriteViewModel>();
                if (isFavorited) {
                  await vm.removeFavorite(userId: userId, eventId: event.id);
                } else {
                  await vm.addFavorite(userId: userId, eventId: event.id);
                }
                break;
              case 'edit':
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.editEvent,
                  arguments: {'event': event},
                );
                break;
              case 'delete':
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Event?'),
                    content: const Text(
                      'Are you sure you want to delete this event? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  try {
                    await context.read<EventViewModel>().deleteEvent(event.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Event deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting event: $e')),
                      );
                    }
                  }
                }
                break;
              case 'participants':
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.participants,
                  arguments: {
                    'eventId': event.id,
                    'creatorId': event.idCreator,
                  },
                );
                break;
              case 'chat':
                Navigator.pushNamed(
                  context,
                  AppRoutes.chat,
                  arguments: {'eventId': event.id, 'title': event.title},
                );
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'favorite',
              child: Row(
                children: [
                  Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Text(isFavorited ? 'Remove Favorite' : 'Add Favorite'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            if (isCreator && !isLocked)
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text('Edit Event'),
                  ],
                ),
              ),
            if (isCreator && event.status == EventStatus.planning)
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Delete Event', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            if (isCreator &&
                (!isLocked || event.status == EventStatus.planning))
              const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'participants',
              child: Row(
                children: [
                  Icon(Icons.people_outline),
                  SizedBox(width: 10),
                  Text('Participants'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'chat',
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline),
                  SizedBox(width: 10),
                  Text('Open Chat'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// Info Row
// ─────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Palette.greenLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Palette.primary, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Palette.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Participants Row
// ─────────────────────────────────────────

class _ParticipantsRow extends StatelessWidget {
  final Event event;

  const _ParticipantsRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final filled = (event.currentUsers / event.maxUsers).clamp(0.0, 1.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Palette.greenLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.group_outlined,
            color: Palette.primary,
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${event.currentUsers} / ${event.maxUsers} participants',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Palette.textSecondary,
                    ),
                  ),
                  Text(
                    '${event.maxUsers - event.currentUsers} left',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: filled,
                  minHeight: 5,
                  backgroundColor: Palette.greenLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Palette.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Image Gallery
// ─────────────────────────────────────────

class _ImageGallery extends StatelessWidget {
  final List<String> imageUrls;

  const _ImageGallery({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Palette.primary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openImage(context, index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrls[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: Palette.greenLight,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Palette.primary,
                      ),
                    ),
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 100,
                        height: 100,
                        color: Palette.greenLight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Palette.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openImage(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) => InteractiveViewer(
                child: Center(
                  child: Image.network(imageUrls[index], fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Join / Leave Button
// ─────────────────────────────────────────

class _JoinLeaveButton extends StatelessWidget {
  final Event event;
  final String userId;
  final bool isLocked;

  const _JoinLeaveButton({
    required this.event,
    required this.userId,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: StreamBuilder<bool>(
        stream: context.read<EventViewModel>().isUserInEvent(
          eventId: event.id,
          userId: userId,
        ),
        builder: (context, snapshot) {
          final isIn = snapshot.data ?? false;
          if (isLocked && !isIn) return const SizedBox.shrink();
          if (event.status != EventStatus.planning && isIn) {
            return const SizedBox.shrink();
          }
          final joining = !isIn;
          return SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: joining ? Palette.primary : Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: Icon(
                joining
                    ? Icons.volunteer_activism_rounded
                    : Icons.exit_to_app_rounded,
              ),
              label: Text(joining ? 'Join Event' : 'Leave Event'),
              onPressed: () async {
                final vm = context.read<EventViewModel>();
                final success = isIn
                    ? await vm.leaveEvent(eventId: event.id, userId: userId)
                    : await vm.joinEvent(eventId: event.id, userId: userId);
                if (success && context.mounted) Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
