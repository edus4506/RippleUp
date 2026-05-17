import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/follow_repository.dart';
import 'package:t5/data/repositories/user_repository.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/viewModels/followers_following_viewModel.dart';
import 'package:t5/viewModels/notification_viewModel.dart';

class FollowersFollowingPage extends StatefulWidget {
  final String userId;
  final int initialTab;

  /// Injected for testing; defaults to FirebaseAuth current user in production.
  final String? currentUserId;

  const FollowersFollowingPage({
    super.key,
    required this.userId,
    this.initialTab = 0,
    this.currentUserId,
  });

  @override
  State<FollowersFollowingPage> createState() => _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends State<FollowersFollowingPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final FollowersFollowingViewModel _vm;
  late final String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = widget.currentUserId ?? _safeFirebaseUid();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _vm = FollowersFollowingViewModel(
      context.read<FollowRepository>(),
      context.read<UserRepository>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.load(widget.userId);
    });
  }

  String? _safeFirebaseUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<FollowersFollowingViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Connections'),
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    text: vm.isLoading
                        ? 'Followers'
                        : 'Followers (${vm.followers.length})',
                  ),
                  Tab(
                    text: vm.isLoading
                        ? 'Following'
                        : 'Following (${vm.following.length})',
                  ),
                ],
              ),
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                ? Center(
                    child: Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _UserList(
                        users: vm.followers,
                        emptyMessage: 'No followers yet.',
                        currentUserId: _currentUserId,
                        vm: vm,
                      ),
                      _UserList(
                        users: vm.following,
                        emptyMessage: 'Not following anyone yet.',
                        currentUserId: _currentUserId,
                        vm: vm,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<MapEntry<String, Users>> users;
  final String emptyMessage;
  final String? currentUserId;
  final FollowersFollowingViewModel vm;

  const _UserList({
    required this.users,
    required this.emptyMessage,
    required this.vm,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final uid = users[index].key;
        final user = users[index].value;
        final isCurrentUser = uid == currentUserId;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profilePictureUrl.isNotEmpty
                ? NetworkImage(user.profilePictureUrl)
                : null,
            child: user.profilePictureUrl.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: isCurrentUser || currentUserId == null
              ? null
              : StreamBuilder<bool>(
                  stream: vm.isFollowing(
                    followerId: currentUserId!,
                    followedId: uid,
                  ),
                  builder: (context, snapshot) {
                    final following = snapshot.data ?? false;
                    return OutlinedButton(
                      onPressed: () async {
                        await vm.toggleFollow(
                          followerId: currentUserId!,
                          followedId: uid,
                          currentlyFollowing: following,
                        );

                        // só envia notificação quando começa a seguir
                        if (!following) {
                          final notificationVm = context
                              .read<AppNotificationViewModel>();

                          final follower = await context
                              .read<UserRepository>()
                              .getUser(currentUserId!);

                          final followed = await context
                              .read<UserRepository>()
                              .getUser(uid);

                          if (follower != null && followed != null) {
                            await notificationVm.createNewFollowerNotification(
                              followed,
                              follower,
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: following ? Colors.red : Colors.green,
                        side: BorderSide(
                          color: following ? Colors.red : Colors.green,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(following ? 'Unfollow' : 'Follow'),
                    );
                  },
                ),
          onTap: isCurrentUser
              ? null
              : () => Navigator.pushNamed(
                  context,
                  AppRoutes.publicProfile,
                  arguments: {'userId': uid},
                ),
        );
      },
    );
  }
}
