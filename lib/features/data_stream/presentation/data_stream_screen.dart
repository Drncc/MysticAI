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
  
  // Cosmic Lab Simulation Values
  double _lunarPhase = 78.0; // %
  bool _isLunarGrowing = true;
  double _schumannHz = 7.83;
  int _solarKp = 2; // 0-9
  
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
    // Initial Random Seed
    final random = Random();
    _lunarPhase = 40 + random.nextDouble() * 50; 
    _isLunarGrowing = random.nextBool();
    _schumannHz = 7.83 + (random.nextDouble() * 1.0 - 0.5);
    _solarKp = random.nextInt(6); // Mostly normal days

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) { // Slower update for Lab Strip
      if (!mounted) return;
      setState(() {
        final r = Random();
        // Existing
        _magneticField = 40.0 + r.nextDouble() * 15.0 - 7.5; 
        
        // Lab Strip Simulation (Subtle changes)
        _schumannHz = 7.83 + (r.nextDouble() * 0.4 - 0.2); // Small fluctuation
        
        // Chaos (depends on Solar Kp slightly)
        double chaosBase = (_solarKp * 5.0) + (r.nextDouble() * 5);
        _chaosLevel = (_chaosLevel * 0.9 + chaosBase * 0.1).clamp(0.0, 100.0);
      });
    });
  }

  Color _getSolarColor(int kp) {
    if (kp < 4) return Colors.greenAccent;
    if (kp < 6) return Colors.orangeAccent;
    return Colors.redAccent;
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
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
              
              const SizedBox(height: 20),

              // KOZMİK LABORATUVAR ŞERİDİ (NEW)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCosmicBadge(
                      title: "AY FAZI",
                      value: "%${_lunarPhase.toInt()} ${_isLunarGrowing ? 'BÜYÜYEN' : 'KÜÇÜLEN'}",
                      icon: Icons.nightlight_round,
                      color: Colors.cyanAccent,
                      delay: 300,
                    ),
                    const SizedBox(width: 12),
                    _buildCosmicBadge(
                      title: "REZONANS",
                      value: "${_schumannHz.toStringAsFixed(2)} Hz",
                      icon: Icons.graphic_eq, // Audio wave
                      color: Colors.greenAccent,
                      delay: 400,
                    ),
                    const SizedBox(width: 12),
                    _buildCosmicBadge(
                      title: "SOLAR AKTİVİTE",
                      value: "Kp: $_solarKp (${_solarKp > 4 ? 'FIRTINA' : 'STABİL'})",
                      icon: Icons.wb_sunny_outlined,
                      color: _getSolarColor(_solarKp),
                      delay: 500,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // BİYOMETRİK DASHBOARD (Existing)
              Text("YEREL VERİ SİNYALLERİ", style: TextStyle(color: Colors.white54, letterSpacing: 1.5, fontSize: 12)),
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
                          Icon(Icons.grain, color: AppTheme.neonCyan, size: 32)
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
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

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

  Widget _buildCosmicBadge({
    required String title, 
    required String value, 
    required IconData icon, 
    required Color color,
    required int delay
  }) {
    return Container(
      width: 130, // Fixed width for uniformity
      height: 100,
      child: GlassCard(
        color: Colors.white.withOpacity(0.05),
        borderColor: color.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const Spacer(),
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 5)]),
                  ).animate(onPlay: (c)=>c.repeat(reverse: true)).fade(duration: 1.seconds)
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    value, 
                    style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ).animate(onPlay: (c)=>c.repeat(reverse: true))
     .scaleXY(end: 1.02, duration: (2000 + delay).ms) // Breathing effect
     .fadeIn(delay: delay.ms).slideX(begin: 0.1);
  }
}
