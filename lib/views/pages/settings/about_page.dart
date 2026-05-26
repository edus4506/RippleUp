import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:t5/theme/palette.dart';
import 'package:t5/views/widgets/top_bar_tabs/top_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4EF),
      appBar: TopBar(
        title: 'About',
        leftWidget: _BackButton(onTap: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Logo + Nome ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Palette.primary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/rippleup_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'RippleUp',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 32,
                      color: Palette.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Palette.greenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Version 1.4.0',
                      style: TextStyle(
                        fontSize: 13,
                        color: Palette.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Missão ──
            _InfoCard(
              icon: Icons.eco_rounded,
              title: 'Our Mission',
              body:
                  'RippleUp connects people who care about the environment. '
                  'We make it easy to find, join, and create local environmental events — '
                  'from beach cleanups to tree planting — so every action creates a ripple effect.',
            ),

            const SizedBox(height: 12),

            // ── Features ──
            _SectionCard(
              icon: Icons.star_outline_rounded,
              title: 'What You Can Do',
              items: const [
                _FeatureItem(
                  icon: Icons.event_rounded,
                  label: 'Discover & join local eco-events',
                ),
                _FeatureItem(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Create and manage your own events',
                ),
                _FeatureItem(
                  icon: Icons.people_outline_rounded,
                  label: 'Connect with like-minded people',
                ),
                _FeatureItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Chat with event participants',
                ),
                _FeatureItem(
                  icon: Icons.notifications_outlined,
                  label: 'Get notified about upcoming events',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Contacto ──
            _InfoCard(
              icon: Icons.mail_outline_rounded,
              title: 'Contact Us',
              body:
                  'Have feedback or need help?\nReach us at support@rippleup.app',
            ),

            const SizedBox(height: 12),

            // ── Full Platform Overview ──
            _SectionCard(
              icon: Icons.dashboard_customize_outlined,
              title: 'Complete Platform Overview',
              items: const [
                _FeatureItem(
                  icon: Icons.login_rounded,
                  label:
                      'Secure authentication system powered by Firebase Authentication with login, registration, logout, password change, and account deletion support.',
                ),
                _FeatureItem(
                  icon: Icons.person_outline_rounded,
                  label:
                      'Custom user profiles with profile pictures, editable information, public profiles, and social interaction features.',
                ),
                _FeatureItem(
                  icon: Icons.group_outlined,
                  label:
                      'Follower and following system allowing users to build a community of environmentally conscious people.',
                ),
                _FeatureItem(
                  icon: Icons.event_available_rounded,
                  label:
                      'Advanced event management system where users can create, edit, join, leave, and delete environmental events.',
                ),
                _FeatureItem(
                  icon: Icons.location_on_outlined,
                  label:
                      'Location-aware events with country, district, and city support to help users discover nearby environmental activities.',
                ),
                _FeatureItem(
                  icon: Icons.filter_alt_outlined,
                  label:
                      'Powerful filtering system with support for environmental goals, event capacity, participant limits, location filters, and event status.',
                ),
                _FeatureItem(
                  icon: Icons.search_rounded,
                  label:
                      'Intelligent event and user search system with optimized matching and debounced search queries for better performance.',
                ),
                _FeatureItem(
                  icon: Icons.favorite_border_rounded,
                  label:
                      'Favorite events system allowing users to save and revisit important or interesting activities.',
                ),
                _FeatureItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label:
                      'Real-time event chat rooms where participants can communicate, coordinate, and interact before and during activities.',
                ),
                _FeatureItem(
                  icon: Icons.forum_outlined,
                  label:
                      'Private direct messaging system with chat previews, unread tracking, last seen support, and real-time conversations.',
                ),
                _FeatureItem(
                  icon: Icons.notifications_active_outlined,
                  label:
                      'Integrated notification system for messages, follows, event updates, participation changes, and upcoming activities.',
                ),
                _FeatureItem(
                  icon: Icons.reviews_outlined,
                  label:
                      'Review and feedback system where users can rate events, leave comments, and view community opinions.',
                ),
                _FeatureItem(
                  icon: Icons.auto_awesome_outlined,
                  label:
                      'Recommendation engine that suggests environmental events based on user activity and community interactions.',
                ),
                _FeatureItem(
                  icon: Icons.eco_outlined,
                  label:
                      'Environmental objective integration allowing events to focus on sustainability goals such as cleanups, recycling, and reforestation.',
                ),
                _FeatureItem(
                  icon: Icons.image_outlined,
                  label:
                      'Image upload and storage support using Supabase Storage for profile pictures and event galleries.',
                ),
                _FeatureItem(
                  icon: Icons.security_outlined,
                  label:
                      'Firestore transactions and validation logic to ensure safe joins, participant limits, and consistent event data.',
                ),
                _FeatureItem(
                  icon: Icons.layers_outlined,
                  label:
                      'Well-structured architecture using repositories, services, models, providers, and view models for maintainability and scalability.',
                ),
                _FeatureItem(
                  icon: Icons.phone_android_outlined,
                  label:
                      'Responsive Flutter interface optimized for mobile and web platforms with modern UI components and animations.',
                ),
                _FeatureItem(
                  icon: Icons.speed_outlined,
                  label:
                      'Pagination, lazy loading, and optimized Firestore queries designed to improve performance and scalability.',
                ),
                _FeatureItem(
                  icon: Icons.palette_outlined,
                  label:
                      'Custom design system with themed colors, reusable widgets, custom navigation bars, dialogs, and polished visual components.',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Footer ──
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '© 2025 RippleUp. All rights reserved.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Info Card ──────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Palette.greenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Palette.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card (com lista) ───────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_FeatureItem> items;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Palette.greenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Palette.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Palette.greenLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: Palette.primary, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String label;
  const _FeatureItem({required this.icon, required this.label});
}

// ── Botão voltar ───────────────────────────────────────────────

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
