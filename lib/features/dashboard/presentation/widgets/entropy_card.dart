import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/glass_card.dart';

class EntropyCard extends ConsumerWidget {
  const EntropyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final screenTime = dashboardState.screenTime;
    final insight = dashboardState.dailyInsight;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ENTROPY SCAN',
                style: GoogleFonts.cinzel(
                  color: AppTheme.neonPurpleLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.neonPurpleLight, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonPurple.withOpacity(0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  'UNIT ONLINE',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.goldAccent,
                        letterSpacing: 1.1,
                      ),
                ).animate().shimmer(duration: 2800.ms),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'SCREEN TIME VECTOR: $screenTime',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            insight,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

