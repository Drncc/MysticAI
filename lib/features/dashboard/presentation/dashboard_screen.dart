import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/biorhythm_card.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/environmental_card.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/digital_entropy_card.dart';

class DashboardScreen extends ConsumerWidget {
  static const path = '/dashboard';
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final username = dashboardState.name ?? 'UNKNOWN UNIT';
    final dailyInsight = dashboardState.dailyInsight;

    // Simple Glitch effect simulation using Flutter Animate
    final glitchText = Text(
      'UNIT [$username] ONLINE',
      style: GoogleFonts.cinzel(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
      delay: 500.ms
    ).swap(
      delay: 50.ms,
      builder: (context, child) => ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: [AppTheme.neonPurple, AppTheme.goldAccent],
            stops: [0.0, 1.0],
          ).createShader(bounds);
        },
        child: Transform.translate(
          offset: const Offset(3, 3),
          child: child,
        ),
      ),
    ).swap(
      delay: 100.ms,
      builder: (context, child) => Transform.translate(
        offset: const Offset(-2, -2),
        child: Text(
          'UNIT [$username] ON-LINE', // intentional slight copy change for glitch feel
          style: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary.withOpacity(0.5),
          ),
        ),
      ),
     ).saturate(
       duration: 300.ms,
     ).shake(
       hz: 10,
       offset: const Offset(1, 1),
       duration: 100.ms
     );


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SYSTEM SYNCHRONIZED',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.goldAccent),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: "Unit [Name] Online" with a glitch effect.
            glitchText,
            
            const SizedBox(height: 20),
            
            // Barnum Insight
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                dailyInsight,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.neonPurpleLight,
                    ),
              ),
            ),
            
            const Divider(color: AppTheme.neonPurpleDark, height: 30),

            // Main Cards
            const BioRhythmCard(),
            const EnvironmentalCard(),
            const DigitalEntropyCard(),

            const SizedBox(height: 40),
            Center(
              child: Text(
                'AWAITING REFLECTION PROTOCOL INPUT.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.goldAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
