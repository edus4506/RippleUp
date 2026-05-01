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
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Palette.background,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // HOME
          GestureDetector(
            onTap: () => onTap(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home,
                  size: 28,
                  color: currentIndex == 0 ? Palette.primary : Colors.grey,
                ),
                const SizedBox(height: 2),
                Text(
                  "Home",
                  style: TextStyle(
                    fontSize: 12,
                    color: currentIndex == 0 ? Palette.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // BOTTON +
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAddPressed,
              borderRadius: BorderRadius.circular(50),
              child: Ink(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Palette.primary,
                  border: Border.all(
                    color: Colors.white, // cor da borda
                    width: 4, // espessura da borda
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),

          // USER
          GestureDetector(
            onTap: () => onTap(1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  size: 28,
                  color: currentIndex == 1 ? Palette.primary : Colors.grey,
                ),
                const SizedBox(height: 2),
                Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 12,
                    color: currentIndex == 1 ? Palette.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
