import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';

class ScientificDashboard extends StatefulWidget {
  final VoidCallback onTarotTap;

  const ScientificDashboard({super.key, required this.onTarotTap});

  @override
  State<ScientificDashboard> createState() => _ScientificDashboardState();
}

class _ScientificDashboardState extends State<ScientificDashboard> {
  // Veriler
  double _magneticField = 45.0;
  double _chaosLevel = 12.0;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _startDataStream();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel(); // KRİTİK: Timer'ı mutlaka öldür
    super.dispose();
  }

  void _startDataStream() {
    // 100ms'de bir çalışan hafif bir zamanlayıcı
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return; // Ekran kapandıysa işlem yapma

      setState(() {
        // Rastgele "Matrix" verileri üret
        final random = Random();
        _magneticField = 40.0 + random.nextDouble() * 10.0; // 40-50 arası
        _chaosLevel = random.nextDouble() * 100;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- 1. MANYETİK AKIŞ GRAFİĞİ (SİMÜLASYON) ---
        GlassCard(
          borderColor: Colors.cyanAccent.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("MANYETİK AKI (µT)", style: AppTheme.interStyle.copyWith(color: Colors.white70)),
                Text(
                  _magneticField.toStringAsFixed(3), 
                  style: AppTheme.orbitronStyle.copyWith(color: Colors.cyanAccent),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 10),

        // --- 2. KAOS SEVİYESİ (PROGRESS BAR) ---
        GlassCard(
          borderColor: Colors.purpleAccent.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("DİJİTAL ENTROPİ", style: AppTheme.interStyle.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _chaosLevel / 100,
                  backgroundColor: Colors.white10,
                  color: Colors.purpleAccent,
                  minHeight: 4,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // --- 3. ANA BUTON (TIKLAMA GARANTİLİ) ---
        GestureDetector(
          onTap: () {
            print("Butona Basıldı - Tetikleniyor...");
            widget.onTarotTap();
          },
          child: GlassCard(
            borderColor: Colors.purpleAccent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
                  const SizedBox(width: 10),
                  Text(
                    "ENERJİNİ KARTA MÜHÜRLE",
                    style: AppTheme.orbitronStyle.copyWith(
                      color: Colors.purpleAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
