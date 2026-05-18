import 'package:flutter/material.dart';

import '../widgets/notification_dropdown.dart';

import 'search_events_page.dart';
import 'search_users_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NotificationDropdown(),

        centerTitle: true,

        title: const Text("Discover"),

        actions: const [SizedBox(width: 48)],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _HoverCard(
              icon: Icons.search,
              title: "Search Events",
              description:
                  "Find environmental activities near you using smart search.",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchEventsPage()),
                );
              },
            ),

            _HoverCard(
              icon: Icons.person_outline,
              title: "Search Users",
              description:
                  "Discover people with similar interests and connect together.",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchUsersPage()),
                );
              },
            ),

            Container(
              width: double.infinity,
              height: 260,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _HoverCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
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
        onTap: widget.onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 18),

          decoration: BoxDecoration(
            color: isHovered ? const Color(0xFFF5F5F5) : Colors.white,

            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isHovered ? 20 : 12),

                blurRadius: isHovered ? 16 : 12,

                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,

                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F3),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Icon(
                  widget.icon,
                  size: 42,
                  color: const Color(0xFF0A7A3E),
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      widget.title,

                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.description,

                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, color: Color(0xFF0A7A3E)),
            ],
          ),
        ),
      ),
    );
  }
}
