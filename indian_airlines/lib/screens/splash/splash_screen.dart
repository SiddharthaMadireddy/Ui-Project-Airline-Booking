import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/app_logo.dart';

/// Animated splash screen showing soaring airplane and brand reveal
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _planeAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _planeAnimation = Tween<double>(begin: -1.2, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
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
      backgroundColor: AppConstants.primaryNavy,
      body: Stack(
        children: [
          // Background Gradient Circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.secondaryNavy.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Center Logo & Brand Name Reveal
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLogo(
                    size: 72,
                    variant: LogoVariant.whiteOnDark,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Connecting India to the World',
                    style: TextStyle(
                      color: AppConstants.saffron,
                      fontSize: 14,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Flying Plane Animation across the screen
          AnimatedBuilder(
            animation: _planeAnimation,
            builder: (context, child) {
              final double x = MediaQuery.sizeOf(context).width * _planeAnimation.value;
              final double y = MediaQuery.sizeOf(context).height * 0.45 -
                  (sin((_planeAnimation.value + 1) * 1.5) * 50);

              return Positioned(
                left: x,
                top: y,
                child: Transform.rotate(
                  angle: -0.25,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Contrail jet smoke
                      Container(
                        width: 80,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppConstants.saffron.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.flight,
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Bottom educational project note
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text(
                'External Lab Project • Fictional Airline',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
