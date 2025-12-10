import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// --- Constants ---
const Color kNeonCyan = Color(0xFF00FFFF);
const Color kNeonBlue = Color(0xFF0055FF);
const Color kVoidBlack = Color(0xFF000000);

class TheGeometricOracle extends StatefulWidget {
  final double size;

  const TheGeometricOracle({super.key, this.size = 200});

  @override
  State<TheGeometricOracle> createState() => _TheGeometricOracleState();
}

class _TheGeometricOracleState extends State<TheGeometricOracle> with TickerProviderStateMixin {
  // --- Controllers ---
  late AnimationController _frameController; // Slow rotation
  late AnimationController _blinkController; // Tech-blink (vertical collapse)
  
  // --- Physics State ---
  Offset _targetLook = Offset.zero;
  Offset _currentLook = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    // 1. Holy Frame Rotation (Very Slow)
    _frameController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    // 2. Tech Blink (Sharp, glitchy)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _startGlitchRoutine();
  }

  void _startGlitchRoutine() async {
    while (mounted) {
      final delay = math.Random().nextInt(4000) + 2000;
      await Future.delayed(Duration(milliseconds: delay));
      if (!mounted) return;
      
      // Snap close
      await _blinkController.forward().orCancel;
      // Hold for a tiny moment
      await Future.delayed(const Duration(milliseconds: 50));
      // Snap open
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
    // Limit range to keep inside the almond shape roughly
    final maxRange = widget.size * 0.15; 
    
    final delta = event.localPosition - center;
    final dist = delta.distance;
    final angle = delta.direction;
    final clampedDist = math.min(dist, maxRange);

    setState(() {
      _targetLook = Offset(
        math.cos(angle) * clampedDist, 
        math.sin(angle) * clampedDist
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
            // Mechanical linear interpolation for tracking (Robot feel)
            _currentLook = Offset.lerp(_currentLook, _targetLook, 0.2)!;

            return Stack(
              alignment: Alignment.center,
              children: [
                // LAYER 1: Holy Frame (Rotating Container)
                Transform.rotate(
                  angle: _frameController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: HolyFramePainter(),
                  ),
                ),

                // LAYER 2: Digital Eye (The Vector Shape)
                // Does NOT rotate. Anchored.
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: DigitalEyePainter(
                    lookOffset: _currentLook,
                    blinkValue: _blinkController.value,
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

class HolyFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..color = kNeonCyan.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    // HEXAGON / DIAMOND SHAPE
    // Let's create a 6-sided polygon (Hexagon) rotated 30 degrees (pointy top)
    final path = Path();
    const sides = 6;
    for (int i = 0; i < sides; i++) {
        final angle = (i * 2 * math.pi / sides) + (math.pi / 2); // Start at top
        final point = Offset(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle)
        );
        if (i == 0) {
            path.moveTo(point.dx, point.dy);
        } else {
            path.lineTo(point.dx, point.dy);
        }
    }
    path.close();
    
    // Draw Glow
    canvas.drawPath(path, Paint()
       ..color = kNeonCyan.withValues(alpha: 0.2)
       ..style = PaintingStyle.stroke
       ..strokeWidth = 3
       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
    );
    
    // Draw Sharp Line
    canvas.drawPath(path, paint);
    
    // Draw Nodes (Joints)
    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    for (int i = 0; i < sides; i++) {
        final angle = (i * 2 * math.pi / sides) + (math.pi / 2);
        final point = Offset(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle)
        );
        canvas.drawCircle(point, 2.5, nodePaint);
        // Connection lines to center (optional esoteric feel)
        // canvas.drawLine(center, point, Paint()..color=kNeonBlue.withValues(alpha: 0.1));
    }
    
    // Inner Circle (Sacred Geometry)
    canvas.drawCircle(center, radius * 0.6, Paint()..style=PaintingStyle.stroke..color=kNeonBlue.withValues(alpha: 0.2)..strokeWidth=0.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DigitalEyePainter extends CustomPainter {
  final Offset lookOffset;
  final double blinkValue; // 0.0 (Open) -> 1.0 (Closed/Flat Line)

  DigitalEyePainter({required this.blinkValue, required this.lookOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Eye width uses 70% of available space
    final eyeWidth = size.width * 0.7;
    final eyeHeightOpen = size.height * 0.4;
    
    // Calculate current eye height based on blink
    // If blinkValue is 1.0, height is roughly 0 (just a line)
    final currentHeight = eyeHeightOpen * (1.0 - blinkValue);
    
    // ALMOND SHAPE PATH
    // Left point, Top Control, Right Point, Bottom Control
    // Pts: 
    // Left: center.dx - eyeWidth/2, center.dy
    // Right: center.dx + eyeWidth/2, center.dy
    // Top: center.dx, center.dy - currentHeight/2 (Curve control points need to be higher to make it almond)
    
    final pLeft = Offset(center.dx - eyeWidth/2, center.dy);
    final pRight = Offset(center.dx + eyeWidth/2, center.dy);
    final pTop = Offset(center.dx, center.dy - currentHeight/2);
    final pBottom = Offset(center.dx, center.dy + currentHeight/2);

    final path = Path();
    path.moveTo(pLeft.dx, pLeft.dy);
    // Top Arch
    path.quadraticBezierTo(pTop.dx, pTop.dy - (eyeHeightOpen * 0.1), pRight.dx, pRight.dy);
    // Bottom Arch
    path.quadraticBezierTo(pBottom.dx, pBottom.dy + (eyeHeightOpen * 0.1), pLeft.dx, pLeft.dy);
    path.close();

    // PAINT STYLES
    final neonPaint = Paint()
      ..color = kNeonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final glowPaint = Paint()
      ..color = kNeonBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Draw Eye Shape Glow & Line
    if (blinkValue < 0.95) {
       canvas.drawPath(path, glowPaint);
       canvas.drawPath(path, neonPaint);
    } else {
       // Just a flat line when closed (The Glitch)
       final lineP1 = Offset(center.dx - eyeWidth/2, center.dy);
       final lineP2 = Offset(center.dx + eyeWidth/2, center.dy);
       canvas.drawLine(lineP1, lineP2, glowPaint..strokeWidth=4);
       canvas.drawLine(lineP1, lineP2, neonPaint..strokeWidth=2..color=Colors.white);
    }

    // CROSSHAIRS (Only visible if not fully closed)
    if (blinkValue < 0.8) {
       final crosshairPaint = Paint()
         ..color = kNeonCyan.withValues(alpha: 0.3)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 1;
         
       // Vertical at center
       canvas.drawLine(Offset(center.dx, pTop.dy), Offset(center.dx, pBottom.dy), crosshairPaint);
       // Horizontal at center
       canvas.drawLine(pLeft, pRight, crosshairPaint);
    }

    // THE CORE (PUPIL)
    // Only draw if eye is somewhat open
    if (blinkValue < 0.9) {
        final pupilPos = center + lookOffset;
        
        // Pupil is a Diamond shape (Rhombus)
        final pupilSize = 8.0;
        final pupilPath = Path();
        pupilPath.moveTo(pupilPos.dx, pupilPos.dy - pupilSize); // Top
        pupilPath.lineTo(pupilPos.dx + pupilSize, pupilPos.dy); // Right
        pupilPath.lineTo(pupilPos.dx, pupilPos.dy + pupilSize); // Bottom
        pupilPath.lineTo(pupilPos.dx - pupilSize, pupilPos.dy); // Left
        pupilPath.close();
        
        // Fill Pupil
        canvas.drawPath(pupilPath, Paint()..color = Colors.white..style = PaintingStyle.fill);
        // Glow Pupil
        canvas.drawPath(pupilPath, Paint()..color = kNeonCyan..style = PaintingStyle.stroke..strokeWidth=2..maskFilter=const MaskFilter.blur(BlurStyle.normal, 4));
        
        // Connector lines to pupil (Targeting system)
        final connectorPaint = Paint()..color = kNeonCyan.withValues(alpha: 0.2)..strokeWidth=0.5;
        canvas.drawLine(Offset(pupilPos.dx, center.dy - currentHeight/2), pupilPos, connectorPaint); // Top to Pupil
        canvas.drawLine(Offset(pupilPos.dx, center.dy + currentHeight/2), pupilPos, connectorPaint); // Bottom to Pupil
        canvas.drawLine(Offset(center.dx - eyeWidth/2, pupilPos.dy), pupilPos, connectorPaint); // Left to Pupil
        canvas.drawLine(Offset(center.dx + eyeWidth/2, pupilPos.dy), pupilPos, connectorPaint); // Right to Pupil
    }
  }

  @override
  bool shouldRepaint(covariant DigitalEyePainter oldDelegate) => 
      oldDelegate.blinkValue != blinkValue || oldDelegate.lookOffset != lookOffset;
}
