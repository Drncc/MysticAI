import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/glass_card.dart';

class EnvironmentalCard extends ConsumerWidget {
  const EnvironmentalCard({super.key});

  String _getHumidityInterpretation(int humidity) {
    if (humidity < 30) {
      return 'ATMOSFER KURU, STATİK YÜK BİRİKİYOR';
    } else if (humidity < 60) {
      return 'ATMOSFER DENGELİ, SİNYAL NETLİĞİ İYİ';
    } else if (humidity < 80) {
      return 'NEM ARTIYOR, DALGA BOYU ESNİYOR';
    } else {
      return 'SATÜRASYON KRİTİK, VERİ GLİTÇLERİ OLABİLİR';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final weatherCondition = dashboardState.weatherCondition.toUpperCase();
    final humidity = dashboardState.humidity;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ENVIRONMENTAL SCAN',
                style: GoogleFonts.cinzel(
                  color: AppTheme.neonPurpleLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Icon(Icons.cloud, color: AppTheme.goldAccent, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'WEATHER PROTOCOL: $weatherCondition',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'HUMIDITY INDEX: $humidity%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            _getHumidityInterpretation(humidity),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}