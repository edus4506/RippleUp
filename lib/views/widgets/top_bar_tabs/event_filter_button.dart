import 'package:flutter/material.dart';

import '../../dialogs/event_filter_dialog.dart';

class EventFilterButton extends StatefulWidget {
  const EventFilterButton({super.key});

  @override
  State<EventFilterButton> createState() => _EventFilterButtonState();
}

class _EventFilterButtonState extends State<EventFilterButton> {
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
              ? Colors.white.withOpacity(0.12)
              : Colors.transparent,
        ),

        child: IconButton(
          tooltip: 'Filter Events',

          splashRadius: 24,

          onPressed: () {
            showDialog(
              context: context,

              builder: (_) => const EventFilterDialog(),
            );
          },

          icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
