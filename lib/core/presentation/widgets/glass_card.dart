import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  // NEW PARAMETERS
  final Color? color;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor,
    this.color,
    this.borderRadius,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = BorderRadius.circular(16);
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? defaultBorderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                // Use provided color or default
                color: widget.color ?? Colors.black.withOpacity(0.5),
                borderRadius: widget.borderRadius ?? defaultBorderRadius,
                border: Border.all(
                  color: widget.borderColor ?? Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
