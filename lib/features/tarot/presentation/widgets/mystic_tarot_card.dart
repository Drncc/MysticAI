import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tekno_mistik/features/tarot/data/models/tarot_card_model.dart';

class MysticTarotCard extends StatefulWidget {
  final TarotCard card;
  final bool isRevealed;
  final Color glowColor;
  final VoidCallback? onTap;

  const MysticTarotCard({
    super.key,
    required this.card,
    required this.isRevealed,
    required this.glowColor,
    this.overrideVariantId,
    this.onTap,
  });

  final int? overrideVariantId;

  @override
  State<MysticTarotCard> createState() => _MysticTarotCardState();
}

class _MysticTarotCardState extends State<MysticTarotCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _selectedImagePath; // To persist the random selection per session

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    // Initial check
    if (widget.isRevealed) {
      _controller.value = 1.0;
      _ensureImageSelected();
    }
  }

  @override
  void didUpdateWidget(MysticTarotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed != oldWidget.isRevealed) {
      if (widget.isRevealed) {
        _ensureImageSelected(); // Select image when revealing
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _ensureImageSelected() {
    // Only select if not already selected to avoid flickering on rebuilds
    if (widget.overrideVariantId != null) {
      _selectedImagePath = 'assets/tarot/${widget.card.id}_${widget.card.codeName}_${widget.overrideVariantId}.jpg';
    } else {
      if (widget.overrideVariantId != null) {
      _selectedImagePath = 'assets/tarot/${widget.card.id}_${widget.card.codeName}_${widget.overrideVariantId}.jpg';
    } else {
      _selectedImagePath ??= widget.card.randomImagePath;
    }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isFront = angle >= pi / 2;
          
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isFront 
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi), // Mirror back the front
                  child: _buildFrontSide(),
                )
              : _buildBackSide(),
          );
        },
      ),
    );
  }

  Widget _buildBackSide() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.glowColor.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
        border: Border.all(
          color: widget.glowColor.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/tarot/card_back.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFrontSide() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.glowColor.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
        border: Border.all(
          color: widget.glowColor,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Holographic Image
            // IMPORTANT: Using colorBlendMode to create "Hologram" effect
            // The image acts as a texture over the neon color
            Image.asset(
              _selectedImagePath ?? widget.card.randomImagePath,
              fit: BoxFit.cover,
              color: widget.glowColor, 
              colorBlendMode: BlendMode.hardLight, // Creates the hologram tint
            ),
            
            // Shininess overlay (Fake reflection)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                    Colors.white.withOpacity(0.05),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            
            // Card Name Label
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.black.withOpacity(0.7),
                child: Text(
                  widget.card.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.glowColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
