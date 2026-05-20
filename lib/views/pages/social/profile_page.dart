import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:t5/data/repositories/social/follow_repository.dart';
import 'package:t5/routes/app_routes.dart';
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
  int selectedIndex = 0; // 0=current, 1=history, 2=favorites

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
      appBar: TopBar(
        leftWidget:
            NotificationDropdown(),

        title:
            vm.user?.name ??
            'Profile',

        rightWidget:
            SettingsButton(),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  (vm.user?.profilePictureUrl != null &&
                      vm.user!.profilePictureUrl.isNotEmpty)
                  ? NetworkImage(vm.user!.profilePictureUrl)
                  : null,
              child:
                  (vm.user?.profilePictureUrl == null ||
                      vm.user!.profilePictureUrl.isEmpty)
                  ? const Icon(Icons.person, size: 80)
                  : null,
            ),

            const SizedBox(height: 16),

            if (vm.isLoading)
              const CircularProgressIndicator()
            else ...[
              Text(
                vm.user?.name ?? "No name",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                vm.user?.email ?? "No email",
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 16),
            _OwnFollowCounts(),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.event_rounded,
                      color: selectedIndex == 0 ? Colors.green : Colors.grey,
                    ),
                    tooltip: "Current Events",
                    onPressed: () {
                      setState(() => selectedIndex = 0);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.history,
                      color: selectedIndex == 1 ? Colors.green : Colors.grey,
                    ),
                    tooltip: "Event History",
                    onPressed: () {
                      setState(() => selectedIndex = 1);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: selectedIndex == 2 ? Colors.green : Colors.grey,
                    ),
                    tooltip: "Favorite Events",
                    onPressed: () {
                      setState(() => selectedIndex = 2);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // dynamic content (favorites, history, etc)
            _buildContent(),
          ],
        ),
      ),
    );
  }
}

class _OwnFollowCounts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final followRepo = context.read<FollowRepository>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<int>(
          stream: followRepo.followersCountStream(uid),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return _ProfileCountButton(
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
        const SizedBox(width: 32),
        StreamBuilder<int>(
          stream: followRepo.followingCountStream(uid),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return _ProfileCountButton(
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

class _ProfileCountButton extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onTap;

  const _ProfileCountButton({
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
