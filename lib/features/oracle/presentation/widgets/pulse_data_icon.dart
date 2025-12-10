import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';

class PulseDataIcon extends StatelessWidget {
  final bool isThinking;

  const PulseDataIcon({super.key, required this.isThinking});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Ring (Thinking Pulse)
          if (isThinking)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.3), width: 1),
              ),
            ).animate(onPlay: (c) => c.repeat())
             .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1.seconds)
             .fadeOut(duration: 1.seconds),

          // Core Data Sculpture (Abstract Representation)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.neonPurple, AppTheme.neonCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonCyan.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          ).animate(target: isThinking ? 1 : 0)
           .shimmer(duration: 2.seconds, color: Colors.white)
           .scaleXY(end: 1.1, duration: 500.ms, curve: Curves.easeInOut),
           
           // Glitch Overlay Effect (Optional visual noise)
           if (isThinking)
             const Icon(Icons.code, color: Colors.white24, size: 60)
               .animate(onPlay: (c) => c.repeat(reverse: true))
               .shake(hz: 8, offset: const Offset(2, 2)),
        ],
      ),
    );
  }
}
