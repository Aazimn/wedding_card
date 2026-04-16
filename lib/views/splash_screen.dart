import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weddingcard/views/home.dart';
import 'dart:async';

class WeddingSplashScreen extends StatefulWidget {
  const WeddingSplashScreen({super.key});

  @override
  State<WeddingSplashScreen> createState() => _WeddingSplashScreenState();
}

class _WeddingSplashScreenState extends State<WeddingSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _controller.forward();

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const WeddingCardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1500),
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
      backgroundColor: const Color(0xFFF9F7F5), // Matching Home Screen cream theme
      body: Stack(
        children: [
          // Subtle background texture
          Opacity(
            opacity: 0.03,
            child: Image.network(
              "https://www.transparenttextures.com/patterns/paper-fibers.png",
              repeat: ImageRepeat.repeat,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The Cute Cartoon Couple Illustration
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.1),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Image.asset(
                                "assets/images/weddingcartoon.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          "AAZIM & RASHMIKA",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            letterSpacing: 8,
                            color: Colors.brown.shade800,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "OUR JOURNEY BEGINS",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 12,
                            letterSpacing: 4,
                            color: Colors.brown.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC19A6B)),
                        ),
                      ],
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
