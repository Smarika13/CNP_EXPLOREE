import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cnp_navigator/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    // 1. Slowed down rotation (4 seconds per full turn)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 2. Breathing effect for background and fireflies
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // 3. Entry Fade logic
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeController.forward();

    // 4. Increased loading time to 6 seconds for a "mind-blowing" calm entry
    Timer(const Duration(milliseconds: 6000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthWrapper(),
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
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color forestGreen = Color(0xFF1B5E20);
    const Color deepJungle = Color(0xFF0C2D10);

    return Scaffold(
      backgroundColor: deepJungle,
      body: Stack(
        children: [
          // LAYER 1: Breathing Gradient Background
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8 + (_pulseController.value * 0.4),
                    colors: const [forestGreen, deepJungle],
                  ),
                ),
              );
            },
          ),

          // LAYER 2: Particle Fireflies
          ...List.generate(25, (index) => _buildFirefly(index)),

          // LAYER 3: Minimalist Logo & Loader (No Text)
          Center(
            child: FadeTransition(
              opacity: _fadeController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedLogo(forestGreen),
                  
                  // Massive spacing to create a sense of scale
                  const SizedBox(height: 140),

                  _buildElegantLoader(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo(Color forestGreen) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.15),
            blurRadius: 60,
            spreadRadius: 5,
          )
        ],
      ),
      child: CircleAvatar(
        radius: 75, // Slightly larger since there's no text
        backgroundColor: Colors.white.withOpacity(0.1),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: Icon(Icons.eco, color: forestGreen, size: 60),
        ),
      ),
    );
  }

  Widget _buildElegantLoader() {
    return RotationTransition(
      turns: _rotationController,
      child: SizedBox(
        width: 50,
        height: 50,
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(4, (index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 15,
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFirefly(int index) {
    final random = math.Random(index);
    final size = random.nextDouble() * 3 + 2;
    return Positioned(
      top: random.nextDouble() * MediaQuery.of(context).size.height,
      left: random.nextDouble() * MediaQuery.of(context).size.width,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Opacity(
            opacity: (math.sin(_pulseController.value * math.pi * 2 + index) + 1) / 2,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.greenAccent, blurRadius: 10)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}