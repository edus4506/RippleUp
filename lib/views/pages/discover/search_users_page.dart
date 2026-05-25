import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_routes.dart';
import '../../../viewModels/search/search_users_viewModel.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SearchUsersViewModel>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SearchUsersViewModel>();
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          // ── Top Bar ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: topPadding + 12, bottom: 16),
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
            child: Stack(
              children: [
                // Ícones decorativos
                Positioned(
                  top: -7,
                  left: 65,
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: -7,
                  right: 65,
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botão voltar + título
                      Row(
                        children: [
                          _CircleButton(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Search Users',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 32,
                                  color: Colors.white,
                                  height: 1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 44,
                          ), // equilibra o botão da esquerda
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Caixa de pesquisa
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7EF),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search_rounded,
                              color: Colors.green.shade600,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: viewModel.searchController,
                                autofocus: true,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF2E7D32),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search users...',
                                  hintStyle: TextStyle(
                                    color: Colors.green.shade300,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: viewModel.updateSearch,
                              ),
                            ),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: viewModel.searchController,
                              builder: (context, value, _) {
                                if (value.text.isEmpty)
                                  return const SizedBox(width: 14);
                                return IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.green.shade400,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    viewModel.searchController.clear();
                                    viewModel.updateSearch('');
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Lista de utilizadores ──────────────────────────
          Expanded(
            child: viewModel.filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 56,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No users found.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: viewModel.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = viewModel.filteredUsers[index];
                      return _UserCard(user: user);
                    },
                  ),
          ),
        ],
      ),
    );
  }
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
          width: 44,
          height: 44,
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

// ── Card de utilizador ────────────────────────────────────────

class _UserCard extends StatefulWidget {
  final dynamic user;
  const _UserCard({required this.user});

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.publicProfile,
          arguments: {'userId': user.uid},
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovered ? const Color(0xFFF5FBF5) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8F0E9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHovered ? 0.07 : 0.04),
                blurRadius: isHovered ? 14 : 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                ),
                child: ClipOval(
                  child: user.profilePictureUrl.isNotEmpty
                      ? Image.network(
                          user.profilePictureUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, color: Colors.grey),
                        )
                      : const Icon(Icons.person, color: Colors.grey),
                ),
              ),

              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade300,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
