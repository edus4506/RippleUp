import 'package:flutter/material.dart';
import '../../theme/palette.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddPressed;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 12, right: 12, bottom: bottomPad + 10),

      child: Container(
        height: 72,

        decoration: BoxDecoration(
          color: Palette.ink0,

          borderRadius: BorderRadius.circular(28),

          border: Border.all(color: Palette.ink300, width: 1.2),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),

              blurRadius: 16,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              iconActive: Icons.home_rounded,
              label: 'Home',
              active: currentIndex == 0,
              onTap: () => onTap(0),
            ),

            _NavItem(
              icon: Icons.travel_explore_outlined,
              iconActive: Icons.travel_explore,
              label: 'Discover',
              active: currentIndex == 1,
              onTap: () => onTap(1),
            ),

            Expanded(
              child: Center(child: _AddButton(onPressed: onAddPressed)),
            ),

            _NavItem(
              icon: Icons.send_outlined,
              iconActive: Icons.send,
              label: 'Messages',
              active: currentIndex == 2,
              onTap: () => onTap(2),
              rotateIcon: true,
            ),

            _NavItem(
              icon: Icons.person_outline,
              iconActive: Icons.person,
              label: 'Profile',
              active: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),

      child: GestureDetector(
        onTap: widget.onPressed,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 72,
          height: 72,

          decoration: BoxDecoration(
            color: isHovered
                ? Palette.accentDark.withOpacity(0.75)
                : Palette.accentDark,

            shape: BoxShape.circle,

            border: Border.all(color: Palette.ink0, width: 5),

            boxShadow: [
              BoxShadow(
                color: Palette.accentDark.withOpacity(isHovered ? 0.25 : 0.45),

                blurRadius: 18,

                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: const Icon(Icons.add, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData iconActive;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool rotateIcon;

  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.active,
    required this.onTap,
    this.rotateIcon = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? Palette.accentDark : Palette.ink400;

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),

        child: GestureDetector(
          onTap: widget.onTap,

          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  height: 32,

                  decoration: BoxDecoration(
                    color: isHovered
                        ? Colors.grey.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Center(
                    child: Transform.rotate(
                      angle: widget.rotateIcon ? -0.785398 : 0,

                      child: Icon(
                        widget.active ? widget.iconActive : widget.icon,
                        size: 24,
                        color: color,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.label,

                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: widget.active
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
