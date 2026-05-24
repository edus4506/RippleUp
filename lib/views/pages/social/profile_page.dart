import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:t5/data/repositories/social/follow_repository.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/theme/palette.dart';
import 'package:t5/views/widgets/top_bar_tabs/top_bar.dart';
import 'package:t5/views/widgets/top_bar_tabs/notification_dropdown.dart';
import 'package:t5/views/widgets/top_bar_tabs/settings_button.dart';
import '../../../viewModels/social/profile_viewModel.dart';
import 'package:provider/provider.dart';
import '../../widgets/profile_tabs/favorite_events_widget.dart';
import '../../widgets/profile_tabs/current_events_widget.dart';
import '../../widgets/profile_tabs/history_events_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUser();
    });
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return const CurrentEventsWidget();
      case 1:
        return const HistoryEventsWidget();
      case 2:
        return const FavoriteEventsWidget();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4EF),
      appBar: TopBar(
        leftWidget: NotificationDropdown(),
        title: vm.user?.name ?? 'Profile',
        rightWidget: SettingsButton(),
      ),
      body: SingleChildScrollView(
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
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Palette.primary),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Linha: avatar + nome + stats ──
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Palette.primary.withOpacity(0.35),
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child:
                                    (vm.user?.profilePictureUrl != null &&
                                        vm.user!.profilePictureUrl.isNotEmpty)
                                    ? Image.network(
                                        vm.user!.profilePictureUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _avatarPlaceholder(),
                                      )
                                    : _avatarPlaceholder(),
                              ),
                            ),

                            const SizedBox(width: 20),

                            // Nome + stats
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 100.0,
                                    ),
                                    child: Text(
                                      vm.user?.name ?? 'No name',
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 26,
                                        color: Palette.primary,
                                        letterSpacing: -0.5,
                                        height: 1.1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _OwnFollowCounts(),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Email
                        Text(
                          vm.user?.email ?? 'No email',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
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
                    icon: Icons.event_rounded,
                    label: 'Current',
                    selected: selectedIndex == 0,
                    onTap: () => setState(() => selectedIndex = 0),
                  ),
                  _TabButton(
                    icon: Icons.history_rounded,
                    label: 'History',
                    selected: selectedIndex == 1,
                    onTap: () => setState(() => selectedIndex = 1),
                  ),
                  _TabButton(
                    icon: Icons.favorite_rounded,
                    label: 'Favorites',
                    selected: selectedIndex == 2,
                    onTap: () => setState(() => selectedIndex = 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Conteúdo da tab ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildContent(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: Palette.greenLight,
      child: const Icon(Icons.person, size: 44, color: Palette.primary),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : Colors.grey,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
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
// Follow Counts — estilo Instagram (horizontal)
// ─────────────────────────────────────────

class _OwnFollowCounts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final followRepo = context.read<FollowRepository>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StreamBuilder<int>(
          stream: followRepo.followersCountStream(uid),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return _StatColumn(
              label: 'Followers',
              count: count,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.followersFollowing,
                arguments: {'userId': uid, 'initialTab': 0},
              ),
            );
          },
        ),
        Container(width: 1, height: 32, color: Colors.grey.shade200),
        StreamBuilder<int>(
          stream: followRepo.followingCountStream(uid),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return _StatColumn(
              label: 'Following',
              count: count,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.followersFollowing,
                arguments: {'userId': uid, 'initialTab': 1},
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
        children: [
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Palette.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
