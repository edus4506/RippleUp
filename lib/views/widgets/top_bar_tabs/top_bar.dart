import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leftWidget;

  final String title;

  final Widget? rightWidget;

  final double height;

  const TopBar({
    super.key,

    this.leftWidget,

    required this.title,

    this.rightWidget,

    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final totalHeight = height + topPadding;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: totalHeight,
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
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: Stack(
                children: [
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
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 20,
                    child: _buildCircleButton(
                      child:
                          leftWidget ??
                          Opacity(
                            opacity: 0.18,
                            child: Icon(
                              Icons.public,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 20,
                    child: _buildCircleButton(
                      child:
                          rightWidget ??
                          Opacity(
                            opacity: 0.18,
                            child: Icon(
                              Icons.public,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 219,
                        maxWidth: 221,
                      ),
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7EF),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Transform.translate(
                          offset: const Offset(0, -2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.translate(
                                offset: const Offset(0, 2),
                                child: Transform.rotate(
                                  angle: -1.57,
                                  child: Icon(
                                    Icons.grass_rounded,
                                    size: 22,
                                    color: Colors.green.shade300,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  title,
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 40,
                                    color: const Color(0xFF2E7D32),
                                    height: 1,
                                    letterSpacing: -1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Transform.translate(
                                offset: const Offset(0, 2),
                                child: Transform.rotate(
                                  angle: 1.57,
                                  child: Icon(
                                    Icons.grass_rounded,
                                    size: 22,
                                    color: Colors.green.shade300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildCircleButton({required Widget child}) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(width: 52, height: 52, child: Center(child: child)),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + 44);
}
