import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/user_settings_provider.dart';

class DataStreamScreen extends ConsumerStatefulWidget {
  const DataStreamScreen({super.key});

  @override
  ConsumerState<DataStreamScreen> createState() => _DataStreamScreenState();
}

class _DataStreamScreenState extends ConsumerState<DataStreamScreen> {
  double _magneticField = 45.0;
  double _chaosLevel = 12.0;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _startSensorSimulation();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _startSensorSimulation() {
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        final random = Random();
        _magneticField = 40.0 + random.nextDouble() * 15.0 - 7.5; 
        _chaosLevel = (_chaosLevel + (random.nextDouble() * 4 - 2)).clamp(0.0, 100.0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);
    final userName = settings.name.isNotEmpty ? settings.name.toUpperCase() : "GEZGİN";
    final profession = settings.profession.isNotEmpty ? settings.profession.toUpperCase() : "BİLİNMEYEN";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // HEADER
              Text(
                "HOŞGELDİN,",
                style: AppTheme.orbitronStyle.copyWith(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 4),
              Wrap(
                children: [
                  Text(
                    "$profession ",
                    style: AppTheme.orbitronStyle.copyWith(
                      fontSize: 24,
                      color: AppTheme.neonPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$userName.",
                    style: AppTheme.orbitronStyle.copyWith(
                      fontSize: 24,
                      color: AppTheme.neonCyan,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: AppTheme.neonCyan, blurRadius: 20)],
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
              
              const SizedBox(height: 50),

              // BİYOMETRİK DASHBOARD
              Text("KOZMİK VERİ SİNYALLERİ", style: TextStyle(color: Colors.white54, letterSpacing: 1.5, fontSize: 12)),
              const SizedBox(height: 15),
              
              GlassCard(
                borderColor: AppTheme.neonPurple.withOpacity(0.5),
                color: AppTheme.neonPurple.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Magnetic
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("MANYETİK AKI", style: GoogleFonts.inter(color: Colors.white60, fontSize: 12)),
                              Text(
                                "${_magneticField.toStringAsFixed(1)} µT", 
                                style: GoogleFonts.orbitron( // Fixed Font
                                  color: AppTheme.neonPurple, 
                                  fontSize: 24, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          ),
                          Icon(Icons.waves, color: AppTheme.neonPurple, size: 32)
                              .animate(onPlay: (c)=>c.repeat(reverse: true))
                              .scaleXY(end: 1.1, duration: 1000.ms),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: _magneticField / 100,
                        backgroundColor: Colors.white10,
                        color: AppTheme.neonPurple,
                        minHeight: 2,
                      ),
                      const SizedBox(height: 20),
                      
                      // Chaos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("EVRENSEL ENTROPİ", style: GoogleFonts.inter(color: Colors.white60, fontSize: 12)),
                              Text(
                                "%${_chaosLevel.toInt()}",
                                style: GoogleFonts.orbitron(
                                  color: AppTheme.neonCyan, 
                                  fontSize: 24, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          ),
                          Icon(Icons.graphic_eq, color: AppTheme.neonCyan, size: 32)
                            .animate(onPlay: (c)=>c.repeat(reverse: true))
                            .scaleXY(end: 1.1, duration: 1200.ms),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: _chaosLevel / 100,
                        backgroundColor: Colors.white10,
                        color: AppTheme.neonCyan,
                        minHeight: 2,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              const Spacer(),
              
              Center(
                child: Text(
                  "SİSTEM SENKRONİZE EDİLİYOR...",
                  style: GoogleFonts.inter(color: Colors.white24, fontSize: 10, letterSpacing: 2),
                ).animate(onPlay: (c)=>c.repeat()).shimmer(duration: 3.seconds),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
