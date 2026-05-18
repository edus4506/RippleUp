import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

          return Container(
            margin: const EdgeInsets.only(
              bottom: 14,
            ),

            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withAlpha(10),
                  blurRadius: 10,
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
          );
        },
      ),
    );
  }
}