import 'dart:async';
// import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/constants/string_constants.dart';
import 'package:cuk_commit/core/constants/text_styles.dart';
// import 'package:cuk_commit/auth_gate.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _pulseAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.10), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.10, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
          ),
        );

    _animationController.forward();
    _goNext();
  }

  Future<void> _goNext() async {
    // keep splash for ~2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    // Check if user is authenticated
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      // User is not authenticated, show welcome screen
      Navigator.pushReplacementNamed(context, RouteNames.welcome);
    } else {
      // User is authenticated, go to AuthGate to determine next screen
      Navigator.pushReplacementNamed(context, RouteNames.authGate);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.black, Colors.grey.shade900]
                : [
                    AppColors.primary.withOpacity(0.85),
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.95),
                  ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -size.height * 0.2,
              left: -size.width * 0.2,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.95),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.4),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(
                                      isDarkMode ? 0.4 : 0.6,
                                    ),
                                    blurRadius: 50,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.favorite_rounded,
                                  size: 75,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.h1Light.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          AppStrings.tagline,
                          style: AppTextStyles.bodyMediumLight.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
