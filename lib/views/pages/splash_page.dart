import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/theme/palette.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ).drive(Tween(begin: 0.6, end: 1.0));

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ).drive(Tween(begin: 0.0, end: 1.0));

    _controller.forward();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1800)),
      FirebaseAuth.instance.authStateChanges().first,
    ]);

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacementNamed(
      context,
      user != null ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/rippleup_logo.png',
                        fit: BoxFit.cover,
                        width: 180,
                        height: 180,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Ripple Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make a difference, one ripple at a time',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 64),
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
