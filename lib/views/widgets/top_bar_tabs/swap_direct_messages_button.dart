import 'package:flutter/material.dart';

class SwapDMButton extends StatefulWidget {
  final bool showingEvents;

  final VoidCallback onPressed;

  const SwapDMButton({
    super.key,

    required this.showingEvents,

    required this.onPressed,
  });

  @override
  State<SwapDMButton> createState() => _SwapDMButtonState();
}

class _SwapDMButtonState extends State<SwapDMButton> {
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
        duration: const Duration(milliseconds: 180),

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color: isHovered
              ? Colors.white.withOpacity(0.12)
              : Colors.transparent,
        ),

        child: IconButton(
          tooltip: widget.showingEvents
              ? 'Show User Chats'
              : 'Show Event Chats',

          splashRadius: 24,

          onPressed: widget.onPressed,

          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),

            child: Transform.rotate(
              angle: widget.showingEvents ? 0 : 3.14159 / 2,

              child: Icon(
                Icons.autorenew_rounded,

                key: ValueKey(widget.showingEvents),

                color: Colors.white,

                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
