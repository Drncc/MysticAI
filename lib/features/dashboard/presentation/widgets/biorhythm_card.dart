import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/glass_card.dart';

class BioRhythmCard extends ConsumerWidget {
  const BioRhythmCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final age = dashboardState.age ?? 0;
    final height = dashboardState.height ?? 0;

    // Simple mocked energy level
    final energyLevel = ((height / 100) * (100 - age)).round().clamp(0, 100);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BİO-RHYTHM',
            style: GoogleFonts.cinzel(
              color: AppTheme.neonPurpleLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ENERJİ VEKTÖRÜ: %$energyLevel',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.darkGray.withOpacity(0.6),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth * (energyLevel / 100);
                  return AnimatedContainer(
                    duration: 600.ms,
                    curve: Curves.easeOut,
                    width: width,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.neonPurpleLight,
                          AppTheme.goldAccent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonPurple.withOpacity(0.45),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ).animate().shimmer(duration: 1800.ms);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Algoritmik akış stabil, biyo-ritim frekansı yankılanıyor.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}