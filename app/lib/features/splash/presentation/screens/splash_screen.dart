import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../auth/auth_wrapper.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,

          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Stack(
        children: [
          // CYAN GLOW
          Positioned(
            top: 140,
            left: -60,

            child: _buildGlow(color: AppColors.primary, size: 260),
          ),

          // PURPLE GLOW
          Positioned(
            bottom: 120,
            right: -80,

            child: _buildGlow(color: AppColors.purple, size: 240),
          ),

          // MAIN CONTENT
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // LOGO
                  ClipOval(
                    child: SizedBox(
                      width: 160,
                      height: 160,

                      child: Image.asset(
                        'assets/images/crypthera_logo.png',

                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // TITLE
                  Text("Crypthera", style: AppTextStyles.heading1),

                  const SizedBox(height: 12),

                  // TAGLINE
                  Text(
                    "Secure Your Digital Legacy",

                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 90),

                  // DOTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      _buildDot(AppColors.primary),

                      const SizedBox(width: 8),

                      _buildDot(AppColors.textSecondary.withOpacity(0.4)),

                      const SizedBox(width: 8),

                      _buildDot(AppColors.textSecondary.withOpacity(0.4)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // GLOW

  Widget _buildGlow({required Color color, required double size}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),

      child: Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color: color.withOpacity(0.18),
        ),
      ),
    );
  }

  // DOT

  Widget _buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,

      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
