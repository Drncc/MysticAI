import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class TheSingularityEye extends StatefulWidget {
  final double size;

  const TheSingularityEye({super.key, this.size = 300});

  @override
  State<TheSingularityEye> createState() => _TheSingularityEyeState();
}

class _TheSingularityEyeState extends State<TheSingularityEye> with TickerProviderStateMixin {
  // --- Controllers ---
  late AnimationController _pulseController; // Deep breathing (6s)
  late AnimationController _spinController;  // Accretion disk spin
  
  // --- Physics State ---
  Offset _targetLook = Offset.zero;
  Offset _currentLook = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    // Pulse: Deep, slow rhythm (6 seconds)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Spin: Constant slow rotation for the accretion disk/iris
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final localPos = event.localPosition;
    final delta = localPos - center;

    // Clamping: Eye movement contained within the Singularity
    // Max radius reduced for "Heavy" feel
    final maxRadius = (widget.size / 2) * 0.25; 
    
    final distance = delta.distance;
    final angle = delta.direction;
    
    final clampedDistance = math.min(distance, maxRadius);
    
    setState(() {
      _targetLook = Offset(
        math.cos(angle) * clampedDistance,
        math.sin(angle) * clampedDistance,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      onExit: (_) => setState(() => _targetLook = Offset.zero),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _spinController]),
        builder: (context, child) {
          // Physics: EaseOutCubic interpolation for "Heavy/Massive" feel
          // We simulate this frame-by-frame blending
          final double t = 0.05; // Lower = Heavier drag
          _currentLook = Offset.lerp(_currentLook, _targetLook, t)!;

          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: SingularityPainter(
              lookOffset: _currentLook,
              pulseValue: _pulseController.value,
              spinValue: _spinController.value,
            ),
          );
        },
      ),
    );
  }
}

class SingularityPainter extends CustomPainter {
  final Offset lookOffset;
  final double pulseValue;
  final double spinValue;

  SingularityPainter({
    required this.lookOffset,
    required this.pulseValue,
    required this.spinValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Palette
    const colorVoid = Color(0xFF000000);
    const colorDeepIndigo = Color(0xFF0F0B29);
    const colorElectricViolet = Color(0xFF4A00E0);
    const colorColdStarlight = Color(0xFFE0FFFF);

    // --- 1. BACKGROUND VOID (Vignette) ---
    // Outer darkness closing in
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
           colorDeepIndigo.withValues(alpha: 0.2),
           colorVoid,
        ],
        stops: const [0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, bgPaint);


    // --- 2. ACCRETION DISK (Outer Spiral) ---
    // Gaseous ring
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(spinValue * math.pi * 2); // Rotate the whole disk
    
    final diskPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.1
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20) // Gas blur
      ..shader = SweepGradient(
        colors: [
          colorDeepIndigo.withValues(alpha: 0.0),
          colorElectricViolet.withValues(alpha: 0.5),
          colorDeepIndigo.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(math.pi / 4),
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius * 0.8));

    canvas.drawCircle(Offset.zero, radius * 0.7, diskPaint);
    canvas.restore();


    // --- 3. THE GOLDEN IRIS (Logarithmic Spirals) ---
    // The "Eye" part that looks around
    final irisCenter = center + lookOffset;
    final irisRadius = radius * 0.5;

    canvas.save();
    canvas.translate(irisCenter.dx, irisCenter.dy);
    
    // Turbine rotation effect
    // Rotate opposite to accretion disk for mechanical complexity
    canvas.rotate(-spinValue * math.pi * 4); 

    final spiralPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = RadialGradient(
        colors: [colorElectricViolet, Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: irisRadius));

    // Draw multiple spiral arms (Golden Spiral approximation)
    const int armCount = 8;
    for (int i = 0; i < armCount; i++) {
        canvas.save();
        canvas.rotate((math.pi * 2 / armCount) * i);
        
        final Path spiralPath = Path();
        spiralPath.moveTo(0, 0);
        
        // Logarithmic spiral calc: r = a * e^(b * theta)
        for (double t = 0; t < math.pi * 2; t += 0.1) {
           final double r = 5 * math.exp(0.3 * t);
           if (r > irisRadius) break;
           spiralPath.lineTo(r * math.cos(t), r * math.sin(t));
        }
        canvas.drawPath(spiralPath, spiralPaint);
        canvas.restore();
    }
    
    // Inner Iris Glow (Nebula Core)
    final nebulaPaint = Paint()
       ..shader = RadialGradient(
         colors: [
           colorElectricViolet.withValues(alpha: 0.6),
           colorDeepIndigo.withValues(alpha: 0.1),
         ],
       ).createShader(Rect.fromCircle(center: Offset.zero, radius: irisRadius));
    canvas.drawCircle(Offset.zero, irisRadius * 0.8, nebulaPaint);

    canvas.restore();


    // --- 4. THE EVENT HORIZON (Pupil) ---
    // The black hole center
    // Pulsing effect using pulseValue (6s cycle)
    final dilatedRadius = (irisRadius * 0.35) + (pulseValue * 5); 

    // Lens Effect / Photon Ring Background
    // A faint glow behind the black hole
    canvas.drawCircle(
      irisCenter, 
      dilatedRadius + 4, 
      Paint()
        ..color = colorElectricViolet.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
    );

    // Absolute Black Hole
    canvas.drawCircle(
      irisCenter, 
      dilatedRadius, 
      Paint()..color = colorVoid
    );

    // Photon Ring (Sharp bright stroke)
    final photonRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colorColdStarlight.withValues(alpha: 0.9);
      
    canvas.drawCircle(irisCenter, dilatedRadius, photonRingPaint);


    // --- 5. SPECULAR HIGHLIGHT (Glass/Liquid Surface) ---
    // Fixed position relative to screen (light source doesn't move with eye)
    final highlightPaint = Paint()
       ..color = Colors.white.withValues(alpha: 0.15)
       ..style = PaintingStyle.fill;
    
    final highlightPath = Path();
    // Crescent shape
    highlightPath.addOval(Rect.fromCenter(center: center + Offset(0, -radius * 0.2), width: radius * 0.5, height: radius * 0.4));
    
    // Cutout to make it crescent
    final cutoutPath = Path();
    cutoutPath.addOval(Rect.fromCenter(center: center + Offset(0, -radius * 0.1), width: radius * 0.5, height: radius * 0.45));
    
    final finalHighlight = Path.combine(PathOperation.difference, highlightPath, cutoutPath);
    
    canvas.drawPath(finalHighlight, highlightPaint);
    
    // Tint highlight
    canvas.drawCircle(center + Offset(radius * 0.2, -radius * 0.2), 3, Paint()..color = Colors.white.withValues(alpha: 0.8));

  }

  @override
  bool shouldRepaint(covariant SingularityPainter oldDelegate) {
    return oldDelegate.lookOffset != lookOffset ||
           oldDelegate.pulseValue != pulseValue ||
           oldDelegate.spinValue != spinValue;
  }
}
