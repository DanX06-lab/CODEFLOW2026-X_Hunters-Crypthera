import 'dart:ui';

import 'package:flutter/material.dart';

class GlowContainer extends StatelessWidget {
  final double size;
  final Color color;

  const GlowContainer({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}
