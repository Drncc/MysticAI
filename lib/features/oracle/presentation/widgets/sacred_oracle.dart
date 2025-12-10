import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// --- Constants ---
const Color kSacredCyan = Color(0xFF00FFFF);
const Color kSacredPurple = Color(0xFF9D00FF);
const Color kSacredWhite = Color(0xFFFFFFFF);

class TheSacredOracle extends StatefulWidget {
  final double size;

  const TheSacredOracle({super.key, this.size = 200});

  @override
  State<TheSacredOracle> createState() => _TheSacredOracleState();
}

class _TheSacredOracleState extends State<TheSacredOracle> with TickerProviderStateMixin {
  // --- Controllers ---
  late AnimationController _rotateSlowController;   // Outer (Star Web)
  late AnimationController _rotateMediumController; // Middle (Flower)
  late AnimationController _rotateFastController;   // Inner (Data Stream)
  late AnimationController _breathController;       // Global Breathing

  // --- Physics State ---
  Offset _targetLook = Offset.zero;
  Offset _currentLook = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    // 1. Outer Layer: Very Slow CW (60s)
    _rotateSlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // 2. Middle Layer: Medium CCW (30s)
    _rotateMediumController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true); // Reverse for CCW

    // 3. Inner Layer: Fast CW (5s)
    _rotateFastController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // 4. Breathing: Slow Sine Wave (6s)
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotateSlowController.dispose();
    _rotateMediumController.dispose();
    _rotateFastController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    final center = Offset(widget.size / 2, widget.size / 2);
    // Core constrained within the inner mandala
    final maxRange = widget.size * 0.1; 
    
    final delta = event.localPosition - center;
    final dist = delta.distance;
    final angle = delta.direction;
    final clampedDist = math.min(dist, maxRange);

    setState(() {
      _targetLook = Offset(
        math.cos(angle) * clampedDist,
        math.sin(angle) * clampedDist,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      onExit: (_) => setState(() => _targetLook = Offset.zero),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _rotateSlowController, 
            _rotateMediumController, 
            _rotateFastController, 
            _breathController
          ]),
          builder: (context, child) {
            // Physics Smoothing for Core
            _currentLook = Offset.lerp(_currentLook, _targetLook, 0.1)!;

            // Global Breathing Scale (0.9 to 1.0)
            final scale = 0.9 + (_breathController.value * 0.1);

            return Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // LAYER 1: Star Web (Outer) - Rotating CW
                   Transform.rotate(
                     angle: _rotateSlowController.value * 2 * math.pi,
                     child: CustomPaint(
                       size: Size(widget.size, widget.size),
                       painter: StarWebPainter(),
                     ),
                   ),

                   // LAYER 2: Flower Rings (Middle) - Rotating CCW
                   Transform.rotate(
                     angle: _rotateMediumController.value * 2 * math.pi, // Controller creates negative values? No, standard 0..1. 
                     // We set repeat(reverse: true) which goes 0..1..0. 
                     // Wait, user wants CCW rotation. repeat(reverse:false) is 0->1.
                     // To Rotate CCW, we multiply by -1 or use value.
                     // Actually, let's just use the value * -2 * PI.
                     child: Transform.rotate(
                        angle: _rotateMediumController.value * -2 * math.pi, 
                        child: CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: FlowerOfLifePainter(),
                        ),
                     ),
                   ),

                   // LAYER 3: Data Stream (Inner) - Rotating CW Fast
                   Transform.rotate(
                     angle: _rotateFastController.value * 2 * math.pi,
                     child: CustomPaint(
                       size: Size(widget.size, widget.size),
                       painter: DataStreamPainter(),
                     ),
                   ),

                   // LAYER 4: The Divine Pupil (Core) - Tracking
                   // Does NOT rotate with the rest, but moves with gaze
                   Transform.translate(
                     offset: _currentLook,
                     child: CustomPaint(
                       size: Size(widget.size, widget.size),
                       painter: DivinePupilPainter(),
                     ),
                   ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- PAINTERS ---

class StarWebPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = kSacredCyan.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Spiky Star / Web
    // Draw lines connecting points on the circle
    // Connect point i to i+step
    const points = 24;
    const step = 7; // Prime number relative to points usually works well for star polygons
    
    final path = Path();
    for (int i = 0; i < points; i++) {
        final angle1 = (i * 2 * math.pi / points);
        final p1 = Offset(
            center.dx + radius * math.cos(angle1),
            center.dy + radius * math.sin(angle1)
        );
        
        final angle2 = ((i + step) * 2 * math.pi / points);
        final p2 = Offset(
            center.dx + radius * math.cos(angle2),
            center.dy + radius * math.sin(angle2)
        );
        
        if (i == 0) path.moveTo(p1.dx, p1.dy);
        
        // Actually, for a star polygon, we usually draw continuous lines.
        // Let's just draw lines between all connected nodes logic
        canvas.drawLine(p1, p2, paint);
    }
    
    // Outer Circle Ring
    canvas.drawCircle(center, radius, paint);
    
    // Glow
    canvas.drawCircle(center, radius, Paint()..color = kSacredCyan.withValues(alpha: 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FlowerOfLifePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.7; // Slightly smaller than web

    final paint = Paint()
      ..color = kSacredPurple.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Interlocking Rings (Spirograph-ish)
    // Draw N ellipses rotated around center
    const count = 12;
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count);
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      
      // Draw ellipse
      // Offset slightly to create the flower pattern
      final rect = Rect.fromCenter(
        center: Offset(radius * 0.5, 0), 
        width: radius, 
        height: radius * 0.5
      );
      canvas.drawOval(rect, paint);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DataStreamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.35; // Inner area

    final paint = Paint()
      ..color = kSacredCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw 3 concentric dashed rings
    _drawDashedCircle(canvas, center, radius, paint, 12);
    
    final paint2 = Paint()
      ..color = kSacredPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    _drawDashedCircle(canvas, center, radius * 0.8, paint2, 8);

    final paint3 = Paint()
      ..color = kSacredWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    _drawDashedCircle(canvas, center, radius * 0.6, paint3, 6);
  }
  
  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint, int segments) {
      final path = Path();
      // segments = dashes
      final step = (2 * math.pi) / segments;
      final gap = step * 0.3; // 30% gap
      
      for(int i=0; i<segments; i++) {
          final startAngle = i * step;
          final sweepAngle = step - gap;
          path.addArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle);
      }
      canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DivinePupilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // DIAMOND CORE
    final coreSize = 6.0;
    final path = Path();
    path.moveTo(center.dx, center.dy - coreSize); // Top
    path.lineTo(center.dx + coreSize, center.dy); // Right
    path.lineTo(center.dx, center.dy + coreSize); // Bottom
    path.lineTo(center.dx - coreSize, center.dy); // Left
    path.close();
    
    // Fill
    canvas.drawPath(path, Paint()..color = kSacredWhite..style = PaintingStyle.fill);
    
    // Glow Bloom
    canvas.drawPath(path, Paint()
       ..color = kSacredCyan 
       ..style = PaintingStyle.stroke
       ..strokeWidth = 3
       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
    );
    
    // Outer Rays
    final rayPaint = Paint()..color = kSacredCyan.withValues(alpha: 0.5)..strokeWidth=1;
    // Cross
    canvas.drawLine(Offset(center.dx, center.dy - coreSize*2), Offset(center.dx, center.dy + coreSize*2), rayPaint);
    canvas.drawLine(Offset(center.dx - coreSize*2, center.dy), Offset(center.dx + coreSize*2, center.dy), rayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
