import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/core/theme/app_text_styles.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/user_settings_provider.dart';
import 'package:tekno_mistik/features/data_stream/presentation/widgets/cosmic_lab_sheet.dart';

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
    final random = Random();
    _lunarPhase = 40 + random.nextDouble() * 50; 
    _isLunarGrowing = random.nextBool();
    _schumannHz = 7.83 + (random.nextDouble() * 1.0 - 0.5);
    _solarKp = random.nextInt(6); 

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) return;
      setState(() {
        final r = Random();
        _magneticField = 40.0 + r.nextDouble() * 15.0 - 7.5; 
        _schumannHz = 7.83 + (r.nextDouble() * 0.4 - 0.2); 
        
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

  String _getMagneticComment(double val) {
    if (val > 50) return "Yüksek Enerji: Ani kararlardan kaçın.";
    if (val < 40) return "Düşük Akı: İçe dönmek için ideal.";
    return "Dengeli Akış: Üretkenlik için uygun.";
  }

  String _getChaosComment(double val) {
    if (val > 20) return "Türbülans: Risk alma.";
    return "Stabil: Evren seninle uyumlu.";
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
                style: AppTextStyles.h3.copyWith(color: Colors.white70, fontSize: 18),
              ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 4),
              Wrap(
                children: [
                  Text("$profession ", style: AppTextStyles.h2.copyWith(color: AppTheme.neonPurple)),
                  Text("$userName.", style: AppTextStyles.h2.copyWith(color: AppTheme.neonCyan, shadows: [Shadow(color: AppTheme.neonCyan, blurRadius: 20)])),
                ],
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
              
              const SizedBox(height: 20),

              // KOZMİK LABORATUVAR ŞERİDİ
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCosmicBadge(
                      title: "AY FAZI",
                      value: "%${_lunarPhase.toInt()} ${_isLunarGrowing ? 'BÜYÜYEN' : 'KÜÇÜLEN'}",
                      comment: _isLunarGrowing ? "Yeni başlangıçlar zamanı." : "Arınma zamanı.",
                      icon: Icons.nightlight_round,
                      color: Colors.cyanAccent,
                      delay: 300,
                    ),
                    const SizedBox(width: 12),
                    _buildCosmicBadge(
                      title: "REZONANS",
                      value: "${_schumannHz.toStringAsFixed(2)} Hz",
                      comment: "Stabil: Meditasyon için uygun.",
                      icon: Icons.graphic_eq,
                      color: Colors.greenAccent,
                      delay: 400,
                    ),
                    const SizedBox(width: 12),
                    _buildCosmicBadge(
                      title: "SOLAR AKTİVİTE",
                      value: "Kp: $_solarKp",
                      comment: _solarKp > 4 ? "Fırtına: Başın ağrıyabilir." : "Sakin: Enerji akışı temiz.",
                      icon: Icons.wb_sunny_outlined,
                      color: _getSolarColor(_solarKp),
                      delay: 500,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // BİYOMETRİK DASHBOARD
              Text("YEREL VERİ SİNYALLERİ", style: AppTextStyles.bodySmall.copyWith(letterSpacing: 1.5)),
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
                              Text("MANYETİK AKI", style: AppTextStyles.bodySmall),
                              Text("${_magneticField.toStringAsFixed(1)} µT", style: AppTextStyles.h2.copyWith(color: AppTheme.neonPurple)),
                              Text(_getMagneticComment(_magneticField), style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
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
                              Text("EVRENSEL ENTROPİ", style: AppTextStyles.bodySmall),
                              Text("%${_chaosLevel.toInt()}", style: AppTextStyles.h2.copyWith(color: AppTheme.neonCyan)),
                              Text(_getChaosComment(_chaosLevel), style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
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

              const SizedBox(height: 20),
              
              // KOZMİK LABORATUVAR BUTONU (CLEAN DASHBOARD)
              const Spacer(),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => const CosmicLabSheet(),
                    );
                  },
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.neonPurple, Colors.deepPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppTheme.neonPurple.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)
                      ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.science, color: Colors.white, size: 28),
                        const SizedBox(width: 15),
                        Text(
                          "KOZMİK LABORATUVARI AÇ", 
                          style: AppTextStyles.button.copyWith(color: Colors.white, letterSpacing: 1.5)
                        ),
                      ],
                    ),
                  ).animate(onPlay: (c)=>c.repeat(reverse: true)).shimmer(duration: 3.seconds, delay: 2.seconds),
                ),
              ),

              Center(
                child: Text(
                  "SİSTEM SENKRONİZE EDİLİYOR...",
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10, letterSpacing: 2, color: Colors.white24),
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
    required String comment,
    required IconData icon, 
    required Color color,
    required int delay
  }) {
    return Container(
      width: 160, 
      height: 110,
      margin: const EdgeInsets.only(right: 12),
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
                  Text(title, style: AppTextStyles.bodySmall.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(value, style: AppTextStyles.h3.copyWith(fontSize: 14, color: Colors.white), maxLines: 1),
                  const SizedBox(height: 2),
                  Text(comment, style: AppTextStyles.bodySmall.copyWith(fontSize: 9, color: Colors.white60), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              )
            ],
          ),
        ),
      ),
    ).animate(onPlay: (c)=>c.repeat(reverse: true))
     .scaleXY(end: 1.02, duration: (2000 + delay).ms) // Nefes alma efekti
     .fadeIn(delay: delay.ms).slideX(begin: 0.1);
  }
}
