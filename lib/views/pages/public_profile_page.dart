import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/follow_repository.dart';
import 'package:t5/data/repositories/user_repository.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/viewModels/public_profile_viewModel.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  late final PublicProfileViewModel _vm;
  late final String? _currentUserId;

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
            appBar: AppBar(
              title: Text(vm.user?.name ?? 'Profile'),
              centerTitle: true,
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 16,
                    ),
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
                        Text(
                          vm.user?.name ?? 'Unknown User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        _FollowCounts(userId: widget.userId),
                        const SizedBox(height: 8),
                        if (_currentUserId != null &&
                            _currentUserId != widget.userId)
                          StreamBuilder<bool>(
                            stream: vm.isFollowing(
                              followerId: _currentUserId!,
                              followedId: widget.userId,
                            ),
                            builder: (context, snapshot) {
                              final isFollowing = snapshot.data ?? false;

                              return OutlinedButton.icon(
                                onPressed: () => vm.toggleFollow(
                                  followerId: _currentUserId!,
                                  followedId: widget.userId,
                                  currentlyFollowing: isFollowing,
                                ),
                                icon: Icon(
                                  isFollowing
                                      ? Icons.person_remove
                                      : Icons.person_add,
                                  size: 18,
                                ),
                                label: Text(
                                  isFollowing ? 'Unfollow' : 'Follow',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isFollowing
                                      ? Colors.red
                                      : Colors.green,
                                  side: BorderSide(
                                    color: isFollowing
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 40),

                        _SectionTitle(
                          icon: Icons.add_circle_outline,
                          label: 'Created Events',
                          count: vm.createdEvents.length,
                        ),
                        const SizedBox(height: 12),
                        vm.createdEvents.isEmpty
                            ? const _EmptyState(
                                message: 'No events created yet.',
                              )
                            : _EventList(events: vm.createdEvents),
                        const SizedBox(height: 32),
                        _SectionTitle(
                          icon: Icons.event_rounded,
                          label: 'Joined Events',
                          count: vm.joinedEvents.length,
                        ),
                        const SizedBox(height: 12),
                        vm.joinedEvents.isEmpty
                            ? const _EmptyState(
                                message: 'No events joined yet.',
                              )
                            : _EventList(events: vm.joinedEvents),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _FollowCounts extends StatelessWidget {
  final String userId;

  const _FollowCounts({required this.userId});

  @override
  Widget build(BuildContext context) {
    final followRepo = context.read<FollowRepository>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<int>(
          stream: followRepo.followersCountStream(userId),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return _CountButton(
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
        const SizedBox(width: 32),
        StreamBuilder<int>(
          stream: followRepo.followingCountStream(userId),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return _CountButton(
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

class _CountButton extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onTap;

  const _CountButton({
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _SectionTitle({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(message, style: const TextStyle(color: Colors.grey)),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<Event> events;

  const _EventList({required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.event_rounded, color: Colors.green),
            title: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${event.city}, ${event.district}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
