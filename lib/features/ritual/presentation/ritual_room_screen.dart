import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/core/theme/app_text_styles.dart';

class RitualRoomScreen extends StatefulWidget {
  const RitualRoomScreen({super.key});

  @override
  State<RitualRoomScreen> createState() => _RitualRoomScreenState();
}

class _RitualRoomScreenState extends State<RitualRoomScreen> {
  double _progress = 0.0;
  Timer? _timer;
  bool _isComplete = false;
  bool _isPressing = false;

  void _startRitual() {
    setState(() => _isPressing = true);
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      setState(() {
        _progress += 0.015;
      });

      // Haptic / Vibration feedback increasing intensity
      if (await Vibration.hasVibrator() ?? false) {
         if (_progress > 0.8) {
           Vibration.vibrate(duration: 50, amplitude: 255);
         } else if (_progress > 0.5) {
           Vibration.vibrate(duration: 30, amplitude: 128);
         } else {
           HapticFeedback.lightImpact();
         }
      }

      if (_progress >= 1.0) {
        _completeRitual();
      }
    });
  }

  void _stopRitual() {
    _timer?.cancel();
    setState(() {
      _isPressing = false;
      if (!_isComplete) _progress = 0.0;
    });
  }

  void _completeRitual() {
    _timer?.cancel();
    setState(() => _isComplete = true);
    HapticFeedback.heavyImpact();
    // Success sound could occur here
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Darker override
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient
          Container(
             decoration: BoxDecoration(
               gradient: RadialGradient(
                 center: Alignment.center,
                 radius: 1.5,
                 colors: [
                   _isComplete ? AppTheme.neonCyan.withOpacity(0.2) : AppTheme.neonPurple.withOpacity(0.1),
                   Colors.black,
                 ]
               )
             ),
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isComplete)
                  Text(
                    "RİTÜEL İÇİN BASILI TUT",
                    style: AppTextStyles.h3.copyWith(letterSpacing: 2),
                  ).animate(target: _isPressing ? 1 : 0).fade(end: 0.5),

                 const SizedBox(height: 50),

                 GestureDetector(
                   onLongPressStart: (_) => _startRitual(),
                   onLongPressEnd: (_) => _stopRitual(),
                   child: Stack(
                     alignment: Alignment.center,
                     children: [
                        // Outer Glow
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: 200 + (_progress * 100),
                          height: 200 + (_progress * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.neonPurple.withOpacity(0.1 + (_progress * 0.4)),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonPurple.withOpacity(_progress),
                                blurRadius: 20 + (_progress * 50),
                                spreadRadius: _progress * 20
                              )
                            ]
                          ),
                        ),
                        
                        // Core Circle
                        Container(
                          width: 180, height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30, width: 2),
                            gradient: LinearGradient(
                              colors: [Colors.black, AppTheme.neonPurple.withOpacity(0.5)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight
                            )
                          ),
                          child: Center(
                            child: Icon(
                              _isComplete ? Icons.check : Icons.fingerprint,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ),
                        
                        // Progress ring
                        SizedBox(
                          width: 190, height: 190,
                          child: CircularProgressIndicator(
                            value: _progress,
                            color: AppTheme.neonCyan,
                            strokeWidth: 4,
                          ),
                        )
                     ],
                   ),
                 ),

                 const SizedBox(height: 50),

                 if (_isComplete)
                   Column(
                     children: [
                       Text(
                         "NİYET EVRENE KODLANDI",
                         style: AppTextStyles.h2.copyWith(color: AppTheme.neonCyan),
                       ).animate().fadeIn().scale(),
                       const SizedBox(height: 10),
                       Text(
                         "Enerji frekansın yükseltildi.",
                         style: AppTextStyles.bodyMedium,
                       ).animate(delay: 500.ms).fadeIn(),
                       const SizedBox(height: 30),
                       TextButton(
                         onPressed: () => Navigator.pop(context),
                         child: Text("RİTÜELİ SONLANDIR", style: AppTextStyles.button.copyWith(color: Colors.white54)),
                       )
                     ],
                   )
              ],
            ),
          ),
          
          // Back button
          Positioned(
            top: 40, left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white30),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}
