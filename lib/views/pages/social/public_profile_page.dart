import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/events/event_status.dart';
import 'package:t5/data/repositories/events/event_repository.dart';
import 'package:t5/data/repositories/social/follow_repository.dart';
import 'package:t5/data/repositories/social/user_repository.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/theme/palette.dart';
import 'package:t5/viewModels/social/public_profile_viewModel.dart';
import 'package:t5/views/widgets/top_bar_tabs/top_bar.dart';
import 'package:t5/views/widgets/event_card.dart';
import 'package:t5/views/dialogs/event_details_dialog.dart';
import '../messages/direct_chat_page.dart';
import '../../../services/messages/direct_chat_service.dart';
import '../../../data/repositories/messages/direct_message_repository.dart';
import 'package:t5/theme/event_status_colors.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  late final PublicProfileViewModel _vm;
  late final String? _currentUserId;
  int _selectedTab = 0; // 0 = Created, 1 = Joined

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _vm = PublicProfileViewModel(
      context.read<UserRepository>(),
      context.read<EventRepository>(),
      context.read<FollowRepository>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.loadPublicProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<PublicProfileViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF0F4EF),
            appBar: TopBar(
              title: vm.user?.name ?? 'Profile',
              leftWidget: _BackButtonWithOverlay(
                onTap: () => Navigator.pop(context),
              ),
            ),
            body: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Palette.primary),
                  )
                : vm.errorMessage != null
                ? Center(
                    child: Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // ── Card principal ──
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Avatar + nome + stats ──
                              Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 86,
                                    height: 86,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Palette.primary.withOpacity(
                                          0.35,
                                        ),
                                        width: 3,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child:
                                          (vm.user?.profilePictureUrl != null &&
                                              vm
                                                  .user!
                                                  .profilePictureUrl
                                                  .isNotEmpty)
                                          ? Image.network(
                                              vm.user!.profilePictureUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _placeholder(),
                                            )
                                          : _placeholder(),
                                    ),
                                  ),

                                  const SizedBox(width: 20),

                                  // Nome + stats
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vm.user?.name ?? 'Unknown',
                                          style: GoogleFonts.dmSerifDisplay(
                                            fontSize: 26,
                                            color: Palette.primary,
                                            letterSpacing: -0.5,
                                            height: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _FollowCounts(userId: widget.userId),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Email
                              if (vm.user?.email != null &&
                                  vm.user!.email.isNotEmpty)
                                Text(
                                  vm.user!.email,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),

                              // ── Botões Follow + Message ──
                              if (_currentUserId != null &&
                                  _currentUserId != widget.userId) ...[
                                const SizedBox(height: 16),
                                Divider(color: Colors.grey.shade100),
                                const SizedBox(height: 12),
                                StreamBuilder<bool>(
                                  stream: vm.isFollowing(
                                    followerId: _currentUserId,
                                    followedId: widget.userId,
                                  ),
                                  builder: (context, snapshot) {
                                    final isFollowing = snapshot.data ?? false;
                                    return Row(
                                      children: [
                                        // Follow button
                                        Expanded(
                                          child: _OverlayButton(
                                            onTap: () => vm.toggleFollow(
                                              followerId: _currentUserId,
                                              followedId: widget.userId,
                                              currentlyFollowing: isFollowing,
                                            ),
                                            isActive: !isFollowing,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  isFollowing
                                                      ? Icons
                                                            .person_remove_rounded
                                                      : Icons
                                                            .person_add_rounded,
                                                  size: 16,
                                                  color: isFollowing
                                                      ? Colors.red.shade400
                                                      : Colors.white,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  isFollowing
                                                      ? 'Unfollow'
                                                      : 'Follow',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: isFollowing
                                                        ? Colors.red.shade400
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: isFollowing
                                                ? Colors.white
                                                : Palette.primary,
                                            borderColor: isFollowing
                                                ? Colors.red.shade300
                                                : Palette.primary,
                                          ),
                                        ),

                                        // Message button
                                        FutureBuilder<bool>(
                                          future:
                                              DirectChatService.hasExistingChat(
                                                currentUserId: _currentUserId,
                                                otherUserId: widget.userId,
                                                directMessageRepository: context
                                                    .read<
                                                      DirectMessageRepository
                                                    >(),
                                              ),
                                          builder: (context, chatSnap) {
                                            final canMessage =
                                                isFollowing ||
                                                (chatSnap.data ?? false);
                                            if (!canMessage)
                                              return const SizedBox.shrink();
                                            return Row(
                                              children: [
                                                const SizedBox(width: 10),
                                                _OverlayIconButton(
                                                  onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          DirectChatPage(
                                                            otherUserId:
                                                                widget.userId,
                                                            otherUserName:
                                                                vm.user?.name ??
                                                                'User',
                                                          ),
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      Palette.greenLight,
                                                  child: const Icon(
                                                    Icons
                                                        .chat_bubble_outline_rounded,
                                                    color: Palette.primary,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Tab bar ──
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _TabButton(
                                icon: Icons.add_circle_outline_rounded,
                                label: 'Created (${vm.createdEvents.length})',
                                selected: _selectedTab == 0,
                                onTap: () => setState(() => _selectedTab = 0),
                              ),
                              _TabButton(
                                icon: Icons.event_available_rounded,
                                label: 'Joined (${vm.joinedEvents.length})',
                                selected: _selectedTab == 1,
                                onTap: () => setState(() => _selectedTab = 1),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Lista de eventos com EventCard ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: _selectedTab == 0
                              ? _EventList(
                                  events: vm.createdEvents,
                                  onEventTap: (event) => _openEventDetails(context, event),
                                )
                              : _EventList(
                                  events: vm.joinedEvents,
                                  onEventTap: (event) => _openEventDetails(context, event),
                                ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  void _openEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (_) => EventDetailsDialog(event: event),
    );
  }

  Widget _placeholder() => Container(
    color: Palette.greenLight,
    child: const Icon(Icons.person, size: 44, color: Palette.primary),
  );
}

// ─────────────────────────────────────────
// Overlay Button - com hover e click effects
// ─────────────────────────────────────────

class _OverlayButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final bool isActive;

  const _OverlayButton({
    required this.onTap,
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
    this.isActive = true,
  });

  @override
  State<_OverlayButton> createState() => _OverlayButtonState();
}

class _OverlayButtonState extends State<_OverlayButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 42,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.borderColor,
                ),
                boxShadow: [
                  if (_isPressed)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  else if (_isHovered)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Center(child: widget.child),
            ),
            // Overlay escuro no hover/click
            if (_isHovered || _isPressed)
              AnimatedOpacity(
                opacity: _isPressed ? 0.2 : 0.12,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
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
// Overlay Icon Button - versão para ícone
// ─────────────────────────────────────────

class _OverlayIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color backgroundColor;

  const _OverlayIconButton({
    required this.onTap,
    required this.child,
    required this.backgroundColor,
  });

  @override
  State<_OverlayIconButton> createState() => _OverlayIconButtonState();
}

class _OverlayIconButtonState extends State<_OverlayIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Palette.primary.withOpacity(0.2),
                ),
                boxShadow: [
                  if (_isPressed)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  else if (_isHovered)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Center(child: widget.child),
            ),
            // Overlay escuro no hover/click
            if (_isHovered || _isPressed)
              AnimatedOpacity(
                opacity: _isPressed ? 0.2 : 0.12,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
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
// Tab Button
// ─────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Palette.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Follow Counts
// ─────────────────────────────────────────

class _FollowCounts extends StatelessWidget {
  final String userId;

  const _FollowCounts({required this.userId});

  @override
  Widget build(BuildContext context) {
    final followRepo = context.read<FollowRepository>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        StreamBuilder<int>(
          stream: followRepo.followersCountStream(userId),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return _StatColumn(
              label: 'Followers',
              count: count,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.followersFollowing,
                arguments: {'userId': userId, 'initialTab': 0},
              ),
            );
          },
        ),
        Container(
          width: 1,
          height: 32,
          color: Colors.grey.shade200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        StreamBuilder<int>(
          stream: followRepo.followingCountStream(userId),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return _StatColumn(
              label: 'Following',
              count: count,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.followersFollowing,
                arguments: {'userId': userId, 'initialTab': 1},
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onTap;

  const _StatColumn({
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Palette.primary,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Back Button with Overlay
// ─────────────────────────────────────────

class _BackButtonWithOverlay extends StatefulWidget {
  final VoidCallback onTap;

  const _BackButtonWithOverlay({required this.onTap});

  @override
  State<_BackButtonWithOverlay> createState() => _BackButtonWithOverlayState();
}

class _BackButtonWithOverlayState extends State<_BackButtonWithOverlay> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_isPressed ? 0.3 : _isHovered ? 0.15 : 0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Event List com EventCard
// ─────────────────────────────────────────

class _EventList extends StatelessWidget {
  final List<Event> events;
  final Function(Event) onEventTap;

  const _EventList({required this.events, required this.onEventTap});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text('No events.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          onTap: () => onEventTap(event),
        );
      },
    );
  }
}
