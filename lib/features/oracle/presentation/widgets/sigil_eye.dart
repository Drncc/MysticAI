import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// --- Constants ---
const Color kSigilCyan = Color(0xFF00FFFF);
const Color kSigilDimWhite = int.fromEnvironment('dim') == 1 ? Color(0x3DFFFFFF) : Color(0x3DFFFFFF); // ~24% opacity white

class TheSigilEye extends StatefulWidget {
  final double size;

  const TheSigilEye({super.key, this.size = 220});

  @override
  State<TheSigilEye> createState() => _TheSigilEyeState();
}

class _TheSigilEyeState extends State<TheSigilEye> with TickerProviderStateMixin {
  // --- Controllers ---
  late AnimationController _frameController; // Very Slow Rotation (45s)
  late AnimationController _blinkController; // Tech-Blink (Glitch)
  
  // --- Physics State ---
  Offset _targetLook = Offset.zero;
  Offset _currentLook = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    // 1. Frame Rotation
    _frameController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();

    // 2. Tech Blink
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // Fast snap
    );

    _startTechBlinkRoutine();
  }

  void _startTechBlinkRoutine() async {
    while (mounted) {
      final delay = math.Random().nextInt(4000) + 3000; // 3s - 7s
      await Future.delayed(Duration(milliseconds: delay));
      if (!mounted) return;
      
      // Snap Close
      await _blinkController.forward().orCancel;
      // Micro pause (glitch feel)
      await Future.delayed(const Duration(milliseconds: 50));
      // Snap Open
      await _blinkController.reverse().orCancel;
    }
  }

  @override
  void dispose() {
    _frameController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    final center = Offset(widget.size / 2, widget.size / 2);
    // Constrain pupil to stay well within the almond shape
    final maxRange = widget.size * 0.12; 
    
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
          animation: Listenable.merge([_frameController, _blinkController]),
          builder: (context, child) {
            // Mechanical Tracking
            _currentLook = Offset.lerp(_currentLook, _targetLook, 0.2)!;

            return Stack(
              alignment: Alignment.center,
              children: [
                // LAYER 1: The Hex-Frame (Rotating)
                Transform.rotate(
                  angle: _frameController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: HexFramePainter(),
                  ),
                ),

                // LAYER 2: The Lens & Crosshair (Static Base)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: SigilLensPainter(blinkValue: _blinkController.value),
                ),

                // LAYER 3: The Pupil (Moving)
                // Only visible if eye is open
                if (_blinkController.value < 0.8)
                  Transform.translate(
                    offset: _currentLook,
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: CorePainter(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// --- PAINTERS ---

class HexFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = kSigilCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2); // Slight neon glow

    // Hexagon Shape
    final path = Path();
    const sides = 6;
    for (int i = 0; i < sides; i++) {
        // Rotate by 30 deg (pi/6) to make it pointy at top if needed, or flat. 
        // 0 rad starts at right (flat top/bottom).
        // Let's add pi/2 to start at bottom? Or pi/6.
        // pi/6 (30 deg) makes a flat side top/bottom.
        // 0 makes point right/left.
        // User asked for Hexagon or Diamond. Let's do sharp Hexagon.
        final angle = (i * 2 * math.pi / sides); 
        final point = Offset(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle)
        );
        if (i == 0) path.moveTo(point.dx, point.dy);
        else path.lineTo(point.dx, point.dy);
    }
    path.close();
    
    canvas.drawPath(path, paint);

    // Vertices Dots
    final dotPaint = Paint()
      ..color = kSigilCyan
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
    final dotCorePaint = Paint()..color = Colors.white;

    for (int i = 0; i < sides; i++) {
        final angle = (i * 2 * math.pi / sides);
        final point = Offset(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle)
        );
        canvas.drawCircle(point, 3, dotPaint);
        canvas.drawCircle(point, 1.5, dotCorePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SigilLensPainter extends CustomPainter {
  final double blinkValue;

  SigilLensPainter({required this.blinkValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Eye fits inside the frame.
    final eyeWidth = size.width * 0.75;
    final eyeHeightOpen = size.height * 0.45;
    
    // Tech Blink: Height collapses to 0
    final currentHeight = eyeHeightOpen * (1.0 - blinkValue);

    // 1. Crosshairs (Targeting System) - Behind eye
    final crossPaint = Paint()
      ..color = kSigilDimWhite
      ..strokeWidth = 1.0;
    
    // Draw crosshair only if somewhat open
    if (blinkValue < 0.9) {
       // Horizontal
       canvas.drawLine(center - Offset(eyeWidth * 0.6, 0), center + Offset(eyeWidth * 0.6, 0), crossPaint);
       // Vertical (small)
       // canvas.drawLine(center - Offset(0, eyeHeightOpen * 0.6), center + Offset(0, eyeHeightOpen * 0.6), crossPaint);
       
       // Diagonal X markers (Targeting)
       final markerSize = 8.0;
       // Top Left
       canvas.drawLine(center + Offset(-eyeWidth*0.4, -currentHeight*0.4), center + Offset(-eyeWidth*0.4 - markerSize, -currentHeight*0.4 - markerSize), crossPaint);
       // Top Right
       canvas.drawLine(center + Offset(eyeWidth*0.4, -currentHeight*0.4), center + Offset(eyeWidth*0.4 + markerSize, -currentHeight*0.4 - markerSize), crossPaint);
       // Bottom Left
       canvas.drawLine(center + Offset(-eyeWidth*0.4, currentHeight*0.4), center + Offset(-eyeWidth*0.4 - markerSize, currentHeight*0.4 + markerSize), crossPaint);
       // Bottom Right
       canvas.drawLine(center + Offset(eyeWidth*0.4, currentHeight*0.4), center + Offset(eyeWidth*0.4 + markerSize, currentHeight*0.4 + markerSize), crossPaint);
    }

    // 2. The Almond Lens
    final neonPaint = Paint()
      ..color = kSigilCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4); 
    
    final sharpPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Drawing two arcs (Vesica Piscis style)
    final path = Path();
    
    if (blinkValue > 0.95) {
      // Glitch Line (Flat)
      final p1 = Offset(center.dx - eyeWidth/2, center.dy);
      final p2 = Offset(center.dx + eyeWidth/2, center.dy);
      canvas.drawLine(p1, p2, neonPaint..strokeWidth=3);
      canvas.drawLine(p1, p2, sharpPaint);
      
      // Glitch artifacts
      final random = math.Random();
      if (random.nextBool()) {
          canvas.drawLine(p1 + const Offset(10, -5), p1 + const Offset(30, -5), neonPaint..strokeWidth=1);
          canvas.drawLine(p2 + const Offset(-30, 5), p2 + const Offset(-10, 5), neonPaint..strokeWidth=1);
      }
    } else {
      // Almond Shape
      // Left point
      path.moveTo(center.dx - eyeWidth/2, center.dy);
      // Top Curve
      path.quadraticBezierTo(center.dx, center.dy - currentHeight, center.dx + eyeWidth/2, center.dy);
      // Bottom Curve
      path.quadraticBezierTo(center.dx, center.dy + currentHeight, center.dx - eyeWidth/2, center.dy);
      path.close();
      
      // Draw Glow
      canvas.drawPath(path, neonPaint);
      // Draw Sharp inner line
      canvas.drawPath(path, sharpPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SigilLensPainter oldDelegate) => oldDelegate.blinkValue != blinkValue;
}

class CorePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Diamond Pupil
    final pupilRadius = 6.0;
    
    final path = Path();
    path.moveTo(center.dx, center.dy - pupilRadius);
    path.lineTo(center.dx + pupilRadius, center.dy);
    path.lineTo(center.dx, center.dy + pupilRadius);
    path.lineTo(center.dx - pupilRadius, center.dy);
    path.close();
    
    // Fill
    canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.fill);
    
    // Bloom
    canvas.drawPath(path, Paint()
      ..color = kSigilCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
    );
     
    // Pupil Targeting Ring (Small circle around diamond)
    canvas.drawCircle(center, pupilRadius * 1.8, Paint()..color = kSigilCyan.withValues(alpha: 0.5)..style=PaintingStyle.stroke..strokeWidth=0.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
