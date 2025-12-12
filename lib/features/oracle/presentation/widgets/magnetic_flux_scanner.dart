import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/glass_card.dart';

class MagneticFluxScanner extends StatefulWidget {
  const MagneticFluxScanner({super.key});

  @override
  State<MagneticFluxScanner> createState() => _MagneticFluxScannerState();
}

class _MagneticFluxScannerState extends State<MagneticFluxScanner> {
  // Mock data for emulator fallback if sensors specific fails or returns 0
  final List<double> _fluxHistory = List.filled(50, 0.0);
  StreamSubscription<MagnetometerEvent>? _subscription;
  double _currentMagnitude = 0.0;
  bool _isSensorAvailable = true;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _initSensor();
  }

  void _initSensor() {
    // Check Platform first - Don't even try sensors on Desktop unless supported
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
       _startSimulation();
       return;
    }

    // Try real sensor for mobile
    try {
      _subscription = magnetometerEvents.listen(
        (MagnetometerEvent event) {
          final magnitude = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
          if (mounted) {
            setState(() {
              _currentMagnitude = magnitude;
              _updateHistory(magnitude);
              _isSensorAvailable = true;
            });
          }
        },
        onError: (e) {
          if (mounted) {
             _startSimulation();
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
       _startSimulation();
    }

    // Fallback if no events received
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentMagnitude == 0 && _isSensorAvailable && mounted) {
          // Likely an emulator without sensor support
         _startSimulation(); 
      }
    });
  }

  void _startSimulation() {
    if (_simulationTimer != null) return; // Already simulating
    
    if (mounted) {
      setState(() {
        _isSensorAvailable = false;
      });
    }

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _simulateNoise();
    });
  }

  void _simulateNoise() {
    final random = math.Random();
    // Simulate typical Earth field ~30-60 microTesla + noise
    final mockVal = 40.0 + random.nextDouble() * 20 - 10; 
    setState(() {
      _currentMagnitude = mockVal;
      _updateHistory(mockVal);
    });
  }

  void _updateHistory(double value) {
    if (_fluxHistory.isNotEmpty) {
      _fluxHistory.removeAt(0);
    }
    _fluxHistory.add(value);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppTheme.neonCyan.withOpacity( 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.waves, color: AppTheme.neonCyan, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "MANYETİK AKIŞ (µT)",
                      style: GoogleFonts.orbitron(fontSize: 12, color: AppTheme.neonCyan),
                    ),
                  ],
                ),
                Text(
                  _currentMagnitude.toStringAsFixed(3),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12, 
                    color: Colors.white, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Graph Container
            SizedBox(
              height: 60,
              width: double.infinity,
              child: CustomPaint(
                painter: FluxChartPainter(_fluxHistory, AppTheme.neonCyan),
              ),
            ),
            
            if (!_isSensorAvailable) ...[
               const SizedBox(height: 4),
               Text(
                 "SIMULATION MODE", 
                 style: GoogleFonts.orbitron(fontSize: 8, color: Colors.white24)
               ),
            ]
          ],
        ),
      ),
    );
  }
}

class FluxChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  FluxChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Normalize data to fit height
    // Dynamic range based on simulated values (30-60 roughly)
    const double minVal = 20.0;
    const double maxVal = 70.0;
    
    final xStep = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final value = data[i].clamp(minVal, maxVal);
      final normalizedY = 1.0 - ((value - minVal) / (maxVal - minVal));
      final y = normalizedY * size.height;
      final x = i * xStep;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Add glow
    final glowPaint = Paint()
      ..color = color.withOpacity( 0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FluxChartPainter oldDelegate) => true;
}
