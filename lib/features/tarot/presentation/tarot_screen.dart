import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/oracle/presentation/widgets/scientific_dashboard.dart';
import 'package:tekno_mistik/features/tarot/presentation/widgets/mystic_tarot_card.dart';
import 'package:tekno_mistik/features/tarot/services/tarot_service.dart';

class TarotScreen extends StatefulWidget {
  const TarotScreen({super.key});

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen> {

  // RİTÜEL FONKSİYONU
  Future<void> _showCardRitual() async { 
      print("[TarotScreen] Ritual Triggered...");
      
      final selection = await TarotService().drawDailyCard();
      final card = selection.card;
      final variantId = selection.variantId;
      
      if (!mounted) return;

      final random = Random();
      final List<Color> neonColors = [
        AppTheme.neonCyan, 
        AppTheme.neonPurple, 
        AppTheme.errorRed, 
        Colors.amberAccent
      ];
      final glowColor = neonColors[random.nextInt(neonColors.length)];

      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "Ritual",
        barrierColor: Colors.black.withOpacity(0.95), // Darker background for focus
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                     "KOZMİK YANSIMA", 
                     style: AppTheme.orbitronStyle.copyWith(
                       color: glowColor, 
                       fontSize: 24, 
                       shadows: [Shadow(color: glowColor, blurRadius: 20)]
                     )
                   ).animate().fadeIn(duration: 800.ms),
                   const SizedBox(height: 30),
                   
                   SizedBox(
                     width: 300,
                     height: 500,
                     child: MysticTarotCard(
                       card: card,
                       isRevealed: true,
                       glowColor: glowColor,
                       overrideVariantId: variantId,
                       onTap: () => Navigator.of(context).pop(),
                     ),
                   ).animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .shimmer(duration: 2.seconds, delay: 500.ms),
                   
                   const SizedBox(height: 30),
                   
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 40),
                     child: Text(
                       "\"${card.meaning}\"",
                       textAlign: TextAlign.center,
                       style: AppTheme.interStyle.copyWith(
                         color: Colors.white70,
                         fontStyle: FontStyle.italic,
                         fontSize: 16
                       ),
                     ),
                   ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // No back button on main tab
        title: Text("BİYOMETRİK RİTÜEL", style: AppTheme.orbitronStyle.copyWith(fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // DASHBOARD WIDGET'I
                // Tıklama olayını buradaki _showCardRitual fonksiyonuna bağlıyoruz
                ScientificDashboard(
                  onTarotTap: _showCardRitual,
                ),
                const SizedBox(height: 80), // BottomNav için boşluk
              ],
            ),
          ),
        ),
      ),
    );
  }
}
