import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';

class LivingBackground extends StatelessWidget {
  final Widget child;

  const LivingBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Layer: Deep Space
        Container(color: AppTheme.deepSpace),

        // Layer 1: Slow Moving Gradient Blob (Purple)
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.neonPurple.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 10.seconds)
           .move(begin: const Offset(0, 0), end: const Offset(50, 50), duration: 15.seconds),
        ),

        // Layer 2: Slow Moving Gradient Blob (Cyan/Blue)
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.hologramBlue.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8), duration: 12.seconds)
           .move(begin: const Offset(0, 0), end: const Offset(-30, -30), duration: 18.seconds),
        ),
        
        // Layer 3: Noise/Grain Overlay (Optional, simulating "texture")
        // Ensuring content is visible on top
        Positioned.fill(child: child),
      ],
    );
  }
}
