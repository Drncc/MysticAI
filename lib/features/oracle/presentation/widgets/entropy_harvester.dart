import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';

class EntropyHarvester extends StatefulWidget {
  final VoidCallback onHarvestComplete;

  const EntropyHarvester({super.key, required this.onHarvestComplete});

  @override
  State<EntropyHarvester> createState() => _EntropyHarvesterState();
}

class _EntropyHarvesterState extends State<EntropyHarvester> with SingleTickerProviderStateMixin {
  bool _isHarvesting = false;
  double _entropyLevel = 0.0; // 0.0 to 1.0
  StreamSubscription<AccelerometerEvent>? _subscription;
  double _lastShakeIntensity = 0.0;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
       vsync: this, 
       duration: const Duration(seconds: 1)
    )..repeat(reverse: true);
  }

  void _startHarvesting() {
    setState(() {
      _isHarvesting = true;
    });
    
    _subscription = accelerometerEvents.listen((event) {
      // Calculate jerk/movement
      final g = 9.8;
      // Remove gravity roughly
      final x = event.x;
      final y = event.y;
      final z = event.z;
      
      // Simple magnitude deviation from 1g
      final magnitude = math.sqrt(x*x + y*y + z*z);
      final intensity = (magnitude - g).abs(); // Intensity of movement
      
      _lastShakeIntensity = intensity;

      setState(() {
        // Increment faster if shaking hard
        final increment = 0.005 + (intensity * 0.002);
        _entropyLevel += increment;
        
        if (_entropyLevel >= 1.0) {
          _entropyLevel = 1.0;
          _finishHarvesting();
        }
      });
      
      if (intensity > 2.0) {
        HapticFeedback.lightImpact();
      }
    });
  }

  void _stopHarvesting() {
    _subscription?.cancel();
    setState(() {
      _isHarvesting = false;
      // Reset if not complete? Or keep?
      // Let's reset for difficulty
      if (_entropyLevel < 1.0) {
         _entropyLevel = 0.0;
      }
    });
  }

  void _finishHarvesting() {
    _subscription?.cancel();
    setState(() {
      _isHarvesting = false;
    });
    HapticFeedback.heavyImpact();
    widget.onHarvestComplete();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startHarvesting(),
      onLongPressEnd: (_) => _stopHarvesting(),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse = _isHarvesting ? _pulseController.value * 10 : 0.0;
          final shakeOffset = _isHarvesting ? math.sin(DateTime.now().millisecondsSinceEpoch / 50) * _lastShakeIntensity * 2 : 0.0;

          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isHarvesting ? AppTheme.errorRed : AppTheme.neonCyan.withOpacity( 0.3),
                  width: 2,
                ),
                gradient: RadialGradient(
                  colors: [
                    _isHarvesting ? AppTheme.errorRed.withOpacity( 0.2) : AppTheme.neonCyan.withOpacity( 0.05),
                    Colors.transparent,
                  ],
                ),
                boxShadow: _isHarvesting ? [
                   BoxShadow(color: AppTheme.errorRed.withOpacity( 0.5), blurRadius: 20 + pulse),
                ] : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Central Icon / Text
                   Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(
                         _isHarvesting ? Icons.bolt : Icons.fingerprint, 
                         size: 48, 
                         color: _isHarvesting ? Colors.white : AppTheme.neonCyan
                       ),
                       const SizedBox(height: 10),
                       Text(
                         _isHarvesting ? "${(_entropyLevel * 100).toInt()}%" : "BASILI TUT",
                         style: GoogleFonts.orbitron(
                           color: Colors.white,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                       if (_isHarvesting)
                        Text(
                          "KAOS TOPLANIYOR...",
                          style: TextStyle(color: AppTheme.errorRed, fontSize: 10),
                        )
                     ],
                   ),
                   
                   // Progress Circle
                   SizedBox(
                     width: 180,
                     height: 180,
                     child: CircularProgressIndicator(
                       value: _entropyLevel,
                       color: AppTheme.errorRed,
                       backgroundColor: Colors.white10,
                       strokeWidth: 4,
                     ),
                   ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
