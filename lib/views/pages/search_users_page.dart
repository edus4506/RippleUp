import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';

import '../../viewModels/search_users_viewModel.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() =>
      _SearchUsersPageState();
}

class _SearchUsersPageState
    extends State<SearchUsersPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context
          .read<SearchUsersViewModel>()
          .loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel =
        context.watch<SearchUsersViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: viewModel.searchController,
          autofocus: true,

          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
          ),

          onChanged: viewModel.updateSearch,
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: viewModel.filteredUsers.length,

        itemBuilder: (context, index) {
          final user =
              viewModel.filteredUsers[index];

          return _HoverUserCard(user: user);
        },
      ),
    );
  }
}

class _HoverUserCard extends StatefulWidget {
  final dynamic user;

  const _HoverUserCard({
    required this.user,
  });

  @override
  State<_HoverUserCard> createState() =>
      _HoverUserCardState();
}

class _HoverUserCardState
    extends State<_HoverUserCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },

      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.publicProfile,

            arguments: {
              'userId': user.uid,
            },
          );
        },

        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),

          margin: const EdgeInsets.only(
            bottom: 14,
          ),

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color:
                isHovered
                ? const Color(0xFFF5F5F5)
                : Colors.white,

            borderRadius:
                BorderRadius.circular(20),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(
                  isHovered ? 18 : 10,
                ),

                blurRadius:
                    isHovered ? 14 : 10,

                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [
              CircleAvatar(
                radius: 28,

                backgroundImage:
                    user.profilePictureUrl.isNotEmpty
                    ? NetworkImage(
                        user.profilePictureUrl,
                      )
                    : null,

                child:
                    user.profilePictureUrl.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      user.name,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      user.email,

                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}