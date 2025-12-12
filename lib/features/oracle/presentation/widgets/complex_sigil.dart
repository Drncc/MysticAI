import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// --- Constants ---
const Color kSigilCyan = Color(0xFF00FFFF);
const Color kSigilPurple = Color(0xFF9D00FF);
const Color kSigilWhite = Color(0xFFFFFFFF);

class TheComplexSigil extends StatefulWidget {
  final double size;

  const TheComplexSigil({super.key, this.size = 220});

  @override
  State<TheComplexSigil> createState() => _TheComplexSigilState();
}

class _TheComplexSigilState extends State<TheComplexSigil> with TickerProviderStateMixin {
  // --- Controllers ---
  late AnimationController _frameController; // Outer Hex (CW)
  late AnimationController _webController;   // Connection Web (CCW)
  late AnimationController _pulseController; // Subtle Breathing
  
  // --- Physics State ---
  Offset _targetLook = Offset.zero;
  Offset _currentLook = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    // 1. Frame: Slow CW (60s)
    _frameController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // 2. Web: Medium CCW (5s) - Warp Speed
    _webController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: false); 

    // 3. Pulse: Subtle breathing (4s)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _frameController.dispose();
    _webController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    final center = Offset(widget.size / 2, widget.size / 2);
    // Strict clamp within the almond eye
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
          animation: Listenable.merge([_frameController, _webController, _pulseController]),
          builder: (context, child) {
            // Tracking smoothing
            _currentLook = Offset.lerp(_currentLook, _targetLook, 0.15)!;

            return Stack(
              alignment: Alignment.center,
              children: [
                // LAYER 1: The Hex-Frame (Outer) - Rotates CW
                Transform.rotate(
                  angle: _frameController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: HexFramePainter(),
                  ),
                ),

                // LAYER 2: The Star-Web (Middle) - Rotates CCW
                Transform.rotate(
                  angle: -_webController.value * 2 * math.pi, // Negative for CCW
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: StarWebPainter(),
                  ),
                ),

                // LAYER 3: The Central Eye (Static)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: CentralEyePainter(),
                ),

                // LAYER 4: The Pupil (Dynamic)
                Transform.translate(
                  offset: _currentLook,
                  child: Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1), // Breathing pupil
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: PupilPainter(),
                    ),
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
      ..strokeWidth = 1.5;

    // Outer Hexagon
    final path = Path();
    const sides = 6;
    for (int i = 0; i < sides; i++) {
        final angle = (i * 2 * math.pi / sides);
        final point = Offset(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle)
        );
        if (i == 0) path.moveTo(point.dx, point.dy);
        else path.lineTo(point.dx, point.dy);
    }
    path.close();
    
    // Bloom
    canvas.drawPath(path, Paint()..color=kSigilCyan..style=PaintingStyle.stroke..strokeWidth=3..maskFilter=const MaskFilter.blur(BlurStyle.outer, 5));
    // Sharp Line
    canvas.drawPath(path, paint);

    // Vertices Dots
    final dotPaint = Paint()..color = kSigilWhite..style = PaintingStyle.fill;
    for (int i = 0; i < sides; i++) {
        final angle = (i * 2 * math.pi / sides);
        final point = Offset(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle)
        );
        canvas.drawCircle(point, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarWebPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 * 0.95; 
    final innerRadius = size.width / 2 * 0.45; 

    final paint = Paint()
      ..color = kSigilCyan.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
      
    final purplePaint = Paint()
      ..color = kSigilPurple.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const points = 12; 
    
    // 1. Primary Cyan Links
    for (int i = 0; i < points; i++) {
        final angle = (i * 2 * math.pi / points);
        final outerP = Offset(
            center.dx + outerRadius * math.cos(angle),
            center.dy + outerRadius * math.sin(angle)
        );
        
        final innerAngle = angle + (math.pi / 2); 
        final innerP = Offset(
            center.dx + innerRadius * math.cos(innerAngle),
            center.dy + innerRadius * math.sin(innerAngle)
        );
        
        canvas.drawLine(outerP, innerP, paint);
    }
    
    // 2. Secondary Purple Links
    for (int i = 0; i < points; i++) {
        final angle1 = (i * 2 * math.pi / points);
        final p1 = Offset(
            center.dx + outerRadius * math.cos(angle1),
            center.dy + outerRadius * math.sin(angle1)
        );
        
        final angle2 = ((i + 4) * 2 * math.pi / points);
        final p2 = Offset(
            center.dx + outerRadius * math.cos(angle2),
            center.dy + outerRadius * math.sin(angle2)
        );
        
        canvas.drawLine(p1, p2, purplePaint);
    }
    
    // 3. Inner Hexagon Ring
    final path = Path();
    for (int i = 0; i < 6; i++) {
        final angle = (i * 2 * math.pi / 6);
        final p = Offset(
            center.dx + innerRadius * math.cos(angle),
            center.dy + innerRadius * math.sin(angle)
        );
        if (i==0) path.moveTo(p.dx, p.dy); else path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color=kSigilCyan.withValues(alpha: 0.3)..style=PaintingStyle.stroke..strokeWidth=1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CentralEyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Scaled down by 0.6x as requested
    final eyeWidth = size.width * 0.7 * 0.6;
    final eyeHeight = size.height * 0.35 * 0.6;
    
    final paint = Paint()
      ..color = kSigilCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    final glowPaint = Paint()
      ..color = kSigilCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Sharp Almond Shape
    final path = Path();
    path.moveTo(center.dx - eyeWidth/2, center.dy);
    path.quadraticBezierTo(center.dx, center.dy - eyeHeight, center.dx + eyeWidth/2, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + eyeHeight, center.dx - eyeWidth/2, center.dy);
    path.close();
    
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
    
    // Crosshairs
    canvas.drawLine(
        Offset(center.dx, center.dy - eyeHeight * 1.5), 
        Offset(center.dx, center.dy + eyeHeight * 1.5), 
        Paint()..color = kSigilWhite.withValues(alpha: 0.3)..strokeWidth=0.5
    );
    canvas.drawLine(
        Offset(center.dx - eyeWidth * 0.8, center.dy), 
        Offset(center.dx + eyeWidth * 0.8, center.dy), 
        Paint()..color = kSigilWhite.withValues(alpha: 0.3)..strokeWidth=0.5
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PupilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Diamond Core
    // Diamond Core - Scaled down
    final pupilSize = 6.0 * 0.6; // Renamed from size to pupilSize to avoid shadowing
    final path = Path();
    path.moveTo(center.dx, center.dy - pupilSize);
    path.lineTo(center.dx + pupilSize, center.dy);
    path.lineTo(center.dx, center.dy + pupilSize);
    path.lineTo(center.dx - pupilSize, center.dy);
    path.close();
    
    // Fill
    canvas.drawPath(path, Paint()..color = kSigilWhite..style = PaintingStyle.fill);
    
    // Intense Glow
    canvas.drawPath(path, Paint()
       ..color = kSigilPurple 
       ..style = PaintingStyle.stroke
       ..strokeWidth = 3
       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
    );
    
    // Scanning Ray
    // Scanning Ray - Scaled
    canvas.drawLine(
        Offset(center.dx, center.dy - 9),
        Offset(center.dx, center.dy + 9),
        Paint()..color = kSigilCyan.withValues(alpha: 0.6)..strokeWidth=1
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
