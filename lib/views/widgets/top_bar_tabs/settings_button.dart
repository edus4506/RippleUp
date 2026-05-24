import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';

class SettingsButton extends StatefulWidget {
  const SettingsButton({super.key});

  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
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

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color: isHovered
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
        ),

        child: IconButton(
          tooltip: 'Settings',

          splashRadius: 24,

          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.settings);
          },

          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
