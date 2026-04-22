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
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // HOME
          IconButton(
            icon: Icon(
              Icons.home,
              size: 28,
              color: currentIndex == 0
                  ? Palette.primary 
                  : Colors.grey,
            ),
            onPressed: () => onTap(0),
          ),

          // BOTTON +
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAddPressed,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Palette.primary.withAlpha(180), 
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // USER
          IconButton(
            icon: Icon(
              Icons.person,
              size: 28,
              color: currentIndex == 1
                  ? Palette.primary 
                  : Colors.grey,
            ),
            onPressed: () => onTap(1),
          ),
        ],
      ),
    );
  }
}