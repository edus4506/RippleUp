import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/social/user.dart';
import 'package:t5/data/repositories/social/follow_repository.dart';
import 'package:t5/data/repositories/social/user_repository.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/theme/palette.dart';
import 'package:t5/viewModels/social/followers_following_viewModel.dart';
import 'package:t5/viewModels/social/notification_viewModel.dart';
import 'package:t5/views/widgets/top_bar_tabs/top_bar.dart';

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
            backgroundColor: const Color(0xFFF0F4EF),
            appBar: TopBar(
              title: 'Connections',
              leftWidget: InkWell(
                onTap: () => Navigator.pop(context),
                customBorder: const CircleBorder(),
                splashColor: Colors.white.withOpacity(0.25),
                highlightColor: Colors.white.withOpacity(0.15),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            body: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Palette.primary),
                  )
                : vm.errorMessage != null
                    ? _ErrorWidget(message: vm.errorMessage!)
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _TabBar(
                              tabController: _tabController,
                              followerCount: vm.followers.length,
                              followingCount: vm.following.length,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              // 👇 A CORREÇÃO ESTÁ AQUI: AnimatedBuilder
                              child: AnimatedBuilder(
                                animation: _tabController,
                                builder: (context, _) {
                                  return IndexedStack(
                                    index: _tabController.index,
                                    children: [
                                      _UserList(
                                        users: vm.followers,
                                        emptyMessage: 'No followers yet.',
                                        currentUserId: _currentUserId,
                                        vm: vm,
                                        onUserTap: (uid) {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.publicProfile,
                                            arguments: {'userId': uid},
                                          );
                                        },
                                      ),
                                      _UserList(
                                        users: vm.following,
                                        emptyMessage: 'Not following anyone yet.',
                                        currentUserId: _currentUserId,
                                        vm: vm,
                                        onUserTap: (uid) {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.publicProfile,
                                            arguments: {'userId': uid},
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
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
}

class _TabBar extends StatefulWidget {
  final TabController tabController;
  final int followerCount;
  final int followingCount;

  const _TabBar({
    required this.tabController,
    required this.followerCount,
    required this.followingCount,
  });

  @override
  State<_TabBar> createState() => _TabBarState();
}

class _TabBarState extends State<_TabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.tabController.index;
    widget.tabController.addListener(_updateIndex);
  }

  void _updateIndex() {
    setState(() {
      _selectedIndex = widget.tabController.index;
    });
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_updateIndex);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _TabItem(
            label: 'Followers (${widget.followerCount})',
            isSelected: _selectedIndex == 0,
            onTap: () {
              widget.tabController.animateTo(0);
              setState(() => _selectedIndex = 0);
            },
          ),
          _TabItem(
            label: 'Following (${widget.followingCount})',
            isSelected: _selectedIndex == 1,
            onTap: () {
              widget.tabController.animateTo(1);
              setState(() => _selectedIndex = 1);
            },
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: isSelected
              ? Colors.white.withOpacity(0.2)
              : Palette.primary.withOpacity(0.08),
          highlightColor: isSelected
              ? Colors.white.withOpacity(0.1)
              : Palette.primary.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Palette.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<MapEntry<String, Users>> users;
  final String emptyMessage;
  final String? currentUserId;
  final FollowersFollowingViewModel vm;
  final Function(String uid) onUserTap;

  const _UserList({
    required this.users,
    required this.emptyMessage,
    required this.vm,
    required this.onUserTap,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return _EmptyState(message: emptyMessage);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final uid = users[index].key;
        final user = users[index].value;
        final isCurrentUser = uid == currentUserId;

        return Container(
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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Palette.primary.withOpacity(0.25),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: (user.profilePictureUrl.isNotEmpty)
                    ? Image.network(
                        user.profilePictureUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _avatarPlaceholder(),
                      )
                    : _avatarPlaceholder(),
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Palette.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              user.email,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                      return _FollowButton(
                        isFollowing: following,
                        onPressed: () async {
                          await vm.toggleFollow(
                            followerId: currentUserId!,
                            followedId: uid,
                            currentlyFollowing: following,
                          );

                          // Só envia notificação quando começa a seguir
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
                              await notificationVm
                                  .createNewFollowerNotification(
                                followed,
                                follower,
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
            onTap: isCurrentUser ? null : () => onUserTap(uid),
          ),
        );
      },
    );
  }

  Widget _avatarPlaceholder() => Container(
    color: Palette.greenLight,
    child: const Icon(Icons.person, size: 24, color: Palette.primary),
  );
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onPressed;

  const _FollowButton({
    required this.isFollowing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        splashColor: isFollowing
            ? Colors.red.withOpacity(0.1)
            : Palette.primary.withOpacity(0.1),
        highlightColor: isFollowing
            ? Colors.red.withOpacity(0.05)
            : Palette.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: isFollowing ? Colors.red.shade300 : Palette.primary,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isFollowing ? 'Unfollow' : 'Follow',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isFollowing ? Colors.red.shade400 : Palette.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Palette.greenLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 32,
                color: Palette.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
