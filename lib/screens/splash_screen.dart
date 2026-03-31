import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aiq/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // Leveraging the exact deep colors from the provided App Theme
  static const midnightBlue = Color(0xFF081F5C);
  static const jicamaWhite = Color(0xFFFFF9F0);

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Subtle scale down mimicking the Reference 'VENTURES' transition
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    // Navigate to Home screen smoothly via a Shared/Fade Transition
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 1000),
            pageBuilder: (context, animation, secondaryAnimation) => 
                const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: midnightBlue,
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome, 
                          color: jicamaWhite, 
                          size: 38
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'AIQ',
                          style: GoogleFonts.playfairDisplay(
                            color: jicamaWhite,
                            fontSize: 78,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'WORKLOAD INTELLIGENCE',
                          style: GoogleFonts.montserrat(
                            color: jicamaWhite.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 8.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  // Bottom text fades in after the main logo
                  opacity: _controller.value > 0.6 
                      ? (_controller.value - 0.6) * 2.5 
                      : 0.0,
                  child: Center(
                    child: Text(
                      'INITIALIZING SYSTEM',
                      style: GoogleFonts.montserrat(
                        color: jicamaWhite.withOpacity(0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
