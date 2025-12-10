import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// --- Constants / Config ---
const Color kCyberMetalDark = Color(0xFF111111);
const Color kCyberMetalLight = Color(0xFF2A2A2A);
const Color kCyberNeonCyan = Color(0xFF00F0FF);
const Color kCyberNeonPurple = Color(0xFFBC13FE);
const Color kCyberVoid = Color(0xFF000000);

class TheCyberneticEye extends StatefulWidget {
  final double size;

  const TheCyberneticEye({super.key, this.size = 300});

  @override
  State<TheCyberneticEye> createState() => _TheCyberneticEyeState();
}

class _TheCyberneticEyeState extends State<TheCyberneticEye> with TickerProviderStateMixin {
  // --- Controllers ---
  late AnimationController _rotateController; // Gears rotation
  late AnimationController _breathController; // Core pulsing
  late AnimationController _shutterController; // Mechanical blink

  // --- Physics State ---
  Offset _targetLook = Offset.zero;
  Offset _currentLook = Offset.zero;

  @override
  void initState() {
    super.initState();

    // 1. Mechanism Rotation (Slow, constant, heavy)
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 2. Core Breathing (Deep, slow)
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // 3. Shutter Blink (Mechanical Camera Shutter)
    // Quick close (150ms), momentary hold, pull back (300ms)
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _startMechanicalBlinkRoutine();
  }

  void _startMechanicalBlinkRoutine() async {
    while (mounted) {
      // Random interval between 3s and 8s
      final delay = math.Random().nextInt(5000) + 3000;
      await Future.delayed(Duration(milliseconds: delay));
      if (!mounted) return;

      // Close fast
      await _shutterController.animateTo(1.0, duration: const Duration(milliseconds: 100), curve: Curves.easeInQuad);
      // Wait tiny bit
      await Future.delayed(const Duration(milliseconds: 50));
      // Open slower
      await _shutterController.animateTo(0.0, duration: const Duration(milliseconds: 250), curve: Curves.easeOutBack); // Back curve for mechanical bounce
    }
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _breathController.dispose();
    _shutterController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final delta = event.localPosition - center;

    // Heavy Gaze: Look radius limited to 25% of size
    final maxRadius = widget.size * 0.25;
    final dist = delta.distance;
    final angle = delta.direction;
    final clampedDist = math.min(dist, maxRadius);

    setState(() {
      _targetLook = Offset(math.cos(angle) * clampedDist, math.sin(angle) * clampedDist);
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
          animation: Listenable.merge([_rotateController, _breathController, _shutterController]),
          builder: (context, child) {
            // Physics Interpolation (Heavy Weight)
            // Lower value = heavier/slower
            _currentLook = Offset.lerp(_currentLook, _targetLook, 0.08)!;

            return Stack(
              fit: StackFit.expand,
              children: [
                // LAYER 1: The Chassis (Static Body + Circuits)
                CustomPaint(
                  painter: ChassisPainter(),
                ),

                // LAYER 2: The Mechanism (Rotating Gears)
                // Rotates based on _rotateController
                Transform.rotate(
                  angle: _rotateController.value * 2 * math.pi,
                  child: CustomPaint(
                    painter: MechanismPainter(),
                  ),
                ),

                // LAYER 3: The Core (Local Eye Movement)
                // This moves with gaze
                Transform.translate(
                  offset: _currentLook,
                  child: CustomPaint(
                    painter: CorePainter(breathValue: _breathController.value),
                  ),
                ),

                // LAYER 4: The Shutter (Mechanical Blink)
                // Stays centered, covers everything
                CustomPaint(
                  painter: ShutterPainter(value: _shutterController.value),
                ),

                // LAYER 5: Atmosphere (Glass Reflection & Glow)
                // Static overlay
                CustomPaint(
                   painter: AtmospherePainter(),
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

class ChassisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Brushed Metal Base
    final metalPaint = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFF2A2A2A), Color(0xFF111111)],
        stops: const [0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, metalPaint);

    // 2. Etched Circuits (Static procedural lines)
    final circuitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF333333); // Dark etching
    
    // Draw some tech circles
    canvas.drawCircle(center, radius * 0.9, circuitPaint);
    canvas.drawCircle(center, radius * 0.95, circuitPaint);
    
    // Glowing Veins
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = kCyberNeonCyan.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawCircle(center, radius * 0.92, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MechanismPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    // Iris Mechanism Area
    final mechRadius = radius * 0.7;

    final gearPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xFF444444);

    // Draw gear teeth (simplified)
    const int teeth = 24;
    for (int i = 0; i < teeth; i++) {
      final angle = (i * 2 * math.pi) / teeth;
      final outer = Offset(math.cos(angle) * mechRadius, math.sin(angle) * mechRadius);
      final inner = Offset(math.cos(angle) * (mechRadius - 10), math.sin(angle) * (mechRadius - 10));
      canvas.drawLine(center + inner, center + outer, gearPaint);
    }
    
    // Data Rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = kCyberNeonPurple.withValues(alpha: 0.3);
      
    canvas.drawCircle(center, mechRadius - 15, ringPaint);
    canvas.drawCircle(center, mechRadius - 25, ringPaint);
    
    // Triangles / Tech marks
    final markerPaint = Paint()..color = kCyberNeonCyan.withValues(alpha: 0.5);
    canvas.drawCircle(center + Offset(0, -(mechRadius - 20)), 2, markerPaint);
    canvas.drawCircle(center + Offset((mechRadius - 20), 0), 2, markerPaint);
    canvas.drawCircle(center + Offset(0, (mechRadius - 20)), 2, markerPaint);
    canvas.drawCircle(center + Offset(-(mechRadius - 20), 0), 2, markerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CorePainter extends CustomPainter {
  final double breathValue; // 0..1

  CorePainter({required this.breathValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Pupil is much smaller than iris mechanism
    final basePupilRadius = radius * 0.3;
    final pulseRadius = basePupilRadius + (breathValue * 4.0);

    // 1. The Abyss (Black Hole)
    canvas.drawCircle(center, pulseRadius, Paint()..color = Colors.black);

    // 2. High Energy Rim (Neon ring)
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = kCyberNeonCyan
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4); // Glowing stroke

    canvas.drawCircle(center, pulseRadius, rimPaint);
    
    // Sharp inner rim for definition
    canvas.drawCircle(center, pulseRadius, Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=Colors.white.withValues(alpha: 0.8));
    
    // Inner Void Gradient
    // To make it look deep
    final voidPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.black, kCyberNeonPurple.withValues(alpha: 0.2)],
        stops: const [0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: pulseRadius));
    canvas.drawCircle(center, pulseRadius, voidPaint);
  }

  @override
  bool shouldRepaint(covariant CorePainter oldDelegate) => oldDelegate.breathValue != breathValue;
}

class ShutterPainter extends CustomPainter {
  final double value; // 0.0 (Open) -> 1.0 (Closed)

  ShutterPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    if (value <= 0.01) return; // Optimization

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    // We want to cover up to the chassis, or the whole eye. Let's cover the Mechanism + Core.
    // Chassis (outer ring) might remain visible? 
    // Usually eye shutter covers the lens. Let's cover radius * 0.85
    final shutterRadius = radius * 0.85;

    // Number of blades
    const int bladeCount = 6;
    
    // The blades slide in to form a closed iris.
    // A simple way to simulate an aperture closing is drawing triangles/arcs that rotate and move in.
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Rotate the whole shutter assembly slightly as it closes for mechanical feel
    canvas.rotate(value * math.pi / 4); 

    final bladePaint = Paint()
      ..color = kCyberMetalDark
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = kCyberMetalLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Radius of the open aperture
    // value 0 -> openRadius = shutterRadius (fully open? no, fully open means aperture hole is max)
    // value 1 -> openRadius = 0 (closed)
    final currentHoleRadius = shutterRadius * (1.0 - value);

    // To draw blades, we can't just draw a hole. We need to draw the blades overlapping.
    // Each blade is a path.
    // This is complex geometry. Let's approximate:
    // Draw a big circle (shutter) but clip out a polygon/circle in the middle?
    // User wants "Blades".
    // 
    // Constructing a blade:
    // A blade is essentially a segment of the circle that pivots in.
    // Let's use a simpler visual hack if full mechanical simulation is hard:
    // Draw 6 triangles that move towards center.
    
    final path = Path();
    for(int i=0; i<bladeCount; i++) {
        final angle = (i * 2 * math.pi) / bladeCount;
        // The tip of the blade moves from outside to center
        // Open: tip at distance 'shutterRadius'
        // Closed: tip at distance 0
        final dist = shutterRadius * (1.0 - value);
        
        // Vertices for a blade
        // P1: Tip (moves in)
        // P2: Outer Left
        // P3: Outer Right
        // But aperture blades are curved.
        // Let's simplify: Draw a doughnut!
        // No, the prompt specifically asked for "Mechanical Diaphragm".
        // Let's draw 6 angular wedges.
        
        canvas.save();
        canvas.rotate(angle);
        
        // Blade shape
        final bladePath = Path();
        // Start roughly at the edge of the current hole
        // But for a realistic shutter, blades overlap.
        // Let's translate OUT from center based on 'value'
        // Actually, for aperture, blades rotate IN.
        
        // Alternative implementation: 
        // Draw a large circle, but mask it?
        
        // Let's try: Each blade is a large rectangle/triangle anchored outside, rotating in.
        // Anchor point: (shutterRadius, 0) (rotated)
        
        // Pivot/Translation method:
        // Move blade towards center.
        final moveIn = shutterRadius * value; // 0 to radius
        // Actually, let's keep it simple and robust:
        // Draw the "closed" part as a Polygon that expands from outside? 
        // Or specific blade shapes.
        
        // Let's use the standard "Six overlapping circles" method or similar.
        // Or just drawing a list of triangles that meet at center.
        
        // Vertices
        // Center-ish point (Tip)
        // Calculating tip position based on `currentHoleRadius`
        // We need to enclose the area outside `currentHoleRadius`.
        
        // Simple approach: Fill the screen with blades, leaving a hole.
        // But `value` goes to 1.0 (fully closed).
        
        // Let's draw a blade as a path relative to (0,0) which is the hole center.
        // We will rotate the canvas for each blade.
        // Blade covers the sector but starts at `currentHoleRadius`.
        
        // Blade Path (Wedge)
        final blade = Path();
        blade.moveTo(currentHoleRadius, 0); // Tip at hole edge
        blade.lineTo(shutterRadius, -shutterRadius * 0.6); // Outer corner
        blade.lineTo(shutterRadius, shutterRadius * 0.6); // Outer corner
        blade.close();
        
        // This is too simple (triangle). Real blades curve.
        // Let's add a curve.
        final fancyBlade = Path();
        fancyBlade.moveTo(currentHoleRadius, 0);
        fancyBlade.lineTo(shutterRadius * 1.2, -shutterRadius * 0.7);
        fancyBlade.lineTo(shutterRadius * 1.2, shutterRadius * 0.7);
        // Convex hull roughly.
        // To ensure full coverage when closed (value=1, hole=0), the tip is at 0,0.
        // The blade must be wide enough to overlap neighbors.
        
        canvas.drawPath(fancyBlade, bladePaint);
        canvas.drawPath(fancyBlade, borderPaint);
        
        canvas.restore();
    }
    
    // Center Cap (Optional, if blades don't meet perfectly)
    if (value > 0.95) {
       canvas.drawCircle(Offset.zero, 2, bladePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ShutterPainter oldDelegate) => oldDelegate.value != value;
}

class AtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Specular Highlight (Glass Lens Reflection)
    final glossPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
        stops: const [0.0, 0.4],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    // Draw a large glossy reflection on top half
    // Crescent or large oval
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(-20, -20), width: radius * 1.2, height: radius * 0.8),
      glossPaint
    );
    
    // Sharp highlight dot
    canvas.drawCircle(
      center + Offset(radius * 0.4, -radius * 0.4), 
      4, 
      Paint()..color = Colors.white.withValues(alpha: 0.7)
    );
    
    // 2. Outer Glow (Atmosphere)
    // Drawn OUTSIDE the box? CustomPainter clips usually.
    // If clip behavior allows, or we draw inside a padded area. 
    // The widget size is fixed. We assume the eye is slightly smaller than widget size to allow glow.
    // But here we draw strictly inside.
    // Ideally we'd use a Shadow in a Container decoration for outer glow.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
