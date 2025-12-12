import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';

class AnalysisRitualOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const AnalysisRitualOverlay({super.key, required this.onComplete});

  @override
  State<AnalysisRitualOverlay> createState() => _AnalysisRitualOverlayState();
}

class _AnalysisRitualOverlayState extends State<AnalysisRitualOverlay> {
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _startRitual();
  }

  void _startRitual() async {
    // Stage 1: Calibration
    _addLog("> Initializing Bio-Link...");
    await Future.delayed(500.ms);
    _addLog("> Calibrating Magnetometer... OK");
    await Future.delayed(400.ms);
    
    // Stage 2: Crunching
    _addLog("> Compensating for Earth Rotation...");
    await Future.delayed(600.ms);
    _addLog("> Mapping Star Coordinates [RA: 14h 29m]...");
    await Future.delayed(500.ms);
    _addLog("> Calculating Resonance Index... [SYNCED]");
    await Future.delayed(600.ms);
    
    // Stage 3: Finalizing
    _addLog("> DECRYPTING OMEN...");
    await Future.delayed(400.ms);
    
    widget.onComplete();
  }

  void _addLog(String log) {
    if (mounted) {
      setState(() {
        _logs.add(log);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity( 0.95),
      child: Stack(
        children: [
          // Background Matrix Rain Effect
          Positioned.fill(
             child: CustomPaint(
               painter: MatrixRainPainter(),
             ).animate(onPlay: (c) => c.repeat()).custom(
               duration: 2.seconds,
               builder: (context, value, child) {
                  return child; 
               },
             ),
          ),

          // Center Console
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings_suggest, color: AppTheme.neonCyan, size: 60)
                     .animate(onPlay: (c) => c.repeat())
                     .rotate(duration: 2.seconds),
                const SizedBox(height: 30),
                
                // Logs
                Container(
                  width: 300,
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: AppTheme.neonCyan),
                    boxShadow: [BoxShadow(color: AppTheme.neonCyan.withOpacity( 0.3), blurRadius: 20)],
                  ),
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _logs[index],
                          style: GoogleFonts.jetBrainsMono(
                            color: index == _logs.length - 1 ? Colors.white : AppTheme.neonCyan,
                            fontSize: 12,
                          ),
                        ).animate().fade(duration: 500.ms).scale(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MatrixRainPainter extends CustomPainter {
  final Random _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.neonCyan.withOpacity( 0.2)
      ..style = PaintingStyle.fill;
      
    final textStyle = TextStyle(
      color: AppTheme.neonCyan.withOpacity( 0.4),
      fontSize: 14,
      fontFamily: 'monospace'
    );
    
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw random binary
    for (int i = 0; i < 20; i++) {
       final x = _random.nextDouble() * size.width;
       final y = _random.nextDouble() * size.height;
       
       textPainter.text = TextSpan(text: _random.nextBool() ? "1" : "0", style: textStyle);
       textPainter.layout();
       textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; 
}
