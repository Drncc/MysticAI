import 'dart:math' as math;
import 'package:flutter/material.dart';

class CosmicEye extends StatefulWidget {
  final double size;

  const CosmicEye({super.key, this.size = 300});

  @override
  State<CosmicEye> createState() => _CosmicEyeState();
}

class _CosmicEyeState extends State<CosmicEye> with TickerProviderStateMixin {
  // --- Controllers ---
  late AnimationController _breathController;
  late AnimationController _blinkController;
  
  // --- Physics State ---
  Offset _targetLook = Offset.zero;
  Offset _currentLook = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    // Breathing: 4-5s period, subtle scale
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Blinking: Fast close (150ms), Slower open (300ms)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _startRandomBlinking();
  }

  void _startRandomBlinking() async {
    while (mounted) {
      final delay = math.Random().nextInt(3000) + 2000; // 2s - 5s
      await Future.delayed(Duration(milliseconds: delay));
      if (!mounted) return;
      
      await _blinkController.forward().then((_) => _blinkController.reverse());
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    // Calculate new target look based on mouse position
    final center = Offset(widget.size / 2, widget.size / 2);
    final localPos = event.localPosition;
    final delta = localPos - center;

    // Physics: Clamp the look offset to stay within the Sclera
    // Max movement radius = 35% of total size
    final maxRadius = (widget.size / 2) * 0.35; 
    
    final distance = delta.distance;
    final angle = delta.direction; // same as atan2(dy, dx)
    
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
        // Repaint constantly for smooth physics interpolation
        animation: Listenable.merge([_breathController, _blinkController]),
        builder: (context, child) {
          // Frame-based interpolation (simulating physics drag)
          // 0.1 factor gives a nice "liquid" delay
          _currentLook = Offset.lerp(_currentLook, _targetLook, 0.1)!;

          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: CosmicEyePainter(
              lookOffset: _currentLook,
              breathValue: _breathController.value,
              blinkValue: _blinkController.value,
            ),
          );
        },
      ),
    );
  }
}

class CosmicEyePainter extends CustomPainter {
  final Offset lookOffset;
  final double breathValue; // 0.0 -> 1.0
  final double blinkValue;  // 0.0 (Open) -> 1.0 (Closed)

  CosmicEyePainter({
    required this.lookOffset,
    required this.breathValue,
    required this.blinkValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // --- Breathing Effect (Scale) ---
    // Scale varies between 1.0 and 1.05
    final breathScale = 1.0 + (breathValue * 0.05);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(breathScale);
    canvas.translate(-center.dx, -center.dy);
    
    // ------------------------------------------------
    // LAYER A: THE VOID (SCLERA)
    // ------------------------------------------------
    final scleraPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFF1B2735), // Dark Metallic Grey
          Color(0xFF0A0E14), // Deep Space Black
        ],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, scleraPaint);

    // Sclera Shadow Mask (Inner Shadow to make it look spherical)
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: const [Colors.transparent, Colors.black],
        stops: const [0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shadowPaint);

    // ------------------------------------------------
    // LAYER B: THE NEBULA (IRIS)
    // ------------------------------------------------
    final irisRadius = radius * 0.45;
    final irisCenter = center + lookOffset;

    canvas.save();
    // Rotate the iris slowly for "Alive" effect
    // We can use breathValue to drive rotation or a separate controller. 
    // Using breathValue * PI for simple continuous-like motion
    canvas.translate(irisCenter.dx, irisCenter.dy);
    canvas.rotate(breathValue * math.pi * 0.1); 
    canvas.translate(-irisCenter.dx, -irisCenter.dy);

    final irisPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF00F0FF), // Cyan
          Color(0xFFBC13FE), // Magenta
          Color(0xFF7000FF), // Deep Violet
          Color(0xFF007FFF), // Electric Blue
          Color(0xFF00F0FF), // Wrap Cyan
        ],
      ).createShader(Rect.fromCircle(center: irisCenter, radius: irisRadius));

    canvas.drawCircle(irisCenter, irisRadius, irisPaint);
    
    // Filaments (Noise/Lines inside Iris)
    final filamentPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      
    // Draw some random lines radiating from center of iris
    // Fixed seed for consistency across frames
    final random = math.Random(42); 
    for(int i=0; i<40; i++) {
        final angle = random.nextDouble() * 2 * math.pi;
        final len = random.nextDouble() * irisRadius;
        final start = irisCenter + Offset(math.cos(angle) * (irisRadius * 0.3), math.sin(angle) * (irisRadius * 0.3));
        final end = irisCenter + Offset(math.cos(angle) * len, math.sin(angle) * len);
        canvas.drawLine(start, end, filamentPaint);
    }
    
    canvas.restore(); // Undo rotation

    // ------------------------------------------------
    // LAYER C: THE ABYSS (PUPIL)
    // ------------------------------------------------
    final pupilRadius = irisRadius * 0.4 + (breathValue * 2); // Pupil dilates slightly with breath
    final pupilPaint = Paint()..color = Colors.black;
    
    canvas.drawCircle(irisCenter, pupilRadius, pupilPaint);

    // Event Horizon (Rim Light)
    final rimPaint = Paint()
       ..color = const Color(0xFFE0F7FA).withValues(alpha: 0.8)
       ..style = PaintingStyle.stroke
       ..strokeWidth = 1.5
       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    canvas.drawCircle(irisCenter, pupilRadius, rimPaint);

    // ------------------------------------------------
    // LAYER D: THE GLINT (REFLECTION)
    // ------------------------------------------------
    // Static reflections (they don't move with lookOffset, assuming light source is fixed)
    final glintPaint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    
    // Top-Right main reflection
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(radius * 0.3, -radius * 0.3), 
        width: radius * 0.2, 
        height: radius * 0.15
      ), 
      glintPaint
    );
    
    // Bottom-Left subtle reflection
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-radius * 0.2, radius * 0.2), 
        width: radius * 0.1, 
        height: radius * 0.08
      ), 
      glintPaint
    );

    canvas.restore(); // Restore scale

    // ------------------------------------------------
    // LAYER E: EYELIDS (BLINKING)
    // ------------------------------------------------
    if (blinkValue > 0) {
      final lidHeight = blinkValue * radius; // 0 to radius
      final lidPaint = Paint()..color = const Color(0xFF050510); // Background color (DeepSpace)

      // Top Lid
      canvas.drawRect(
        Rect.fromLTRB(
          center.dx - radius - 5, 
          center.dy - radius - 5, 
          center.dx + radius + 5, 
          center.dy - radius + (lidHeight * 2), // Close down
        ), 
        lidPaint
      );
      
      // Bottom Lid
      canvas.drawRect(
        Rect.fromLTRB(
          center.dx - radius - 5, 
          center.dy + radius - (lidHeight * 2), // Close up
          center.dx + radius + 5, 
          center.dy + radius + 5, 
        ), 
        lidPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CosmicEyePainter oldDelegate) {
    return oldDelegate.lookOffset != lookOffset ||
           oldDelegate.breathValue != breathValue ||
           oldDelegate.blinkValue != blinkValue;
  }
}
