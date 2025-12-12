import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/tarot/presentation/widgets/mystic_tarot_card.dart';
import 'package:tekno_mistik/features/tarot/services/tarot_service.dart';
import 'package:tekno_mistik/features/oracle/presentation/providers/oracle_provider.dart';

class ProphecyScreen extends ConsumerStatefulWidget {
  const ProphecyScreen({super.key});

  @override
  ConsumerState<ProphecyScreen> createState() => _ProphecyScreenState();
}

class _ProphecyScreenState extends ConsumerState<ProphecyScreen> {
  
  Future<void> _revealProphecy() async {
    // 1. Basit Sentiment Analizi Simülasyonu
    // Son Oracle mesajını veya ruh halini kontrol edebiliriz
    // Şimdilik Random ağırlık ile "Karanlık" veya "Aydınlık" varyasyon seçimi
    final random = Random();
    int preferredVariant = 1; // Default
    if (random.nextDouble() > 0.7) preferredVariant = 3; // %30 ihtimalle daha karanlık/mistik varyasyon

    // 2. Kart Çek
    final selection = await TarotService().drawDailyCard(preferredVariant: preferredVariant);

    if (!mounted) return;

    // 3. Mistik Dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E1E2C).withOpacity(0.9),
                    const Color(0xFF0F0C29).withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter, 
                  end: Alignment.bottomCenter
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.neonPurple.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(color: AppTheme.neonPurple.withOpacity(0.3), blurRadius: 40, spreadRadius: 0)
                ]
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Text(
                       "KADERİN YANSIMASI", 
                       style: AppTheme.orbitronStyle.copyWith(
                         color: AppTheme.neonCyan, 
                         fontSize: 20,
                         shadows: [Shadow(color: AppTheme.neonCyan, blurRadius: 15)]
                       ),
                       textAlign: TextAlign.center,
                     ),
                     const SizedBox(height: 30),
                     
                     // KART GÖRSELİ
                     // overrideVariantId kullanımı TarotService'den gelen değeri alır
                     SizedBox(
                       height: 380,
                       child: MysticTarotCard(
                         card: selection.card,
                         isRevealed: true,
                         glowColor: AppTheme.neonPurple,
                         overrideVariantId: selection.variantId,
                         onTap: () {},
                       ),
                     ).animate()
                       .scale(duration: 800.ms, curve: Curves.easeOutBack)
                       .shimmer(duration: 2.seconds, delay: 500.ms),
                     
                     const SizedBox(height: 30),
                     
                     // GİZEMLİ METİN (Kart ismi gizli)
                     Text(
                       "\"${selection.card.meaning}\"", // Sadece anlam
                       textAlign: TextAlign.center,
                       style: GoogleFonts.crimsonText( 
                         color: Colors.white.withOpacity(0.95),
                         fontSize: 22,
                         fontStyle: FontStyle.italic,
                         height: 1.4
                       ),
                     ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                     
                     const SizedBox(height: 30),
                     
                     GestureDetector(
                       onTap: () => Navigator.of(context).pop(),
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.white24),
                           borderRadius: BorderRadius.circular(30)
                         ),
                         child: Text(
                           "MÜHRÜ KAPAT",
                           style: GoogleFonts.inter(color: Colors.white60, letterSpacing: 2, fontSize: 10),
                         ),
                       ),
                     )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("KEHANET", style: AppTheme.orbitronStyle.copyWith(letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // RİTÜEL ALANI
              GestureDetector(
                onTap: _revealProphecy,
                child: Container(
                  width: 250, 
                  height: 390,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Card Back Image
                        Image.asset(
                          'assets/tarot/card_back.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF151026),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.white12, size: 60),
                                  SizedBox(height: 10),
                                  Text("GİZEMLİ KART", style: GoogleFonts.orbitron(color: Colors.white12, fontSize: 10))
                                ],
                              ),
                            );
                          },
                        ),
                        // Overlay
                        Container(
                          color: Colors.black.withOpacity(0.2),
                        ),
                        // Pulse Icon
                        Center(
                          child: Icon(Icons.fingerprint, color: AppTheme.neonPurple.withOpacity(0.7), size: 64)
                              .animate(onPlay: (c)=>c.repeat(reverse: true))
                              .scaleXY(end: 1.2, duration: 1.5.seconds)
                              .fade(duration: 1.5.seconds),
                        ),
                      ],
                    ),
                  ),
                ).animate(onPlay: (c)=>c.repeat(reverse: true))
                 .moveY(end: -15, duration: 3.seconds, curve: Curves.easeInOut), // Floating effect
              ),

              const SizedBox(height: 40),

              GlassCard(
                borderColor: AppTheme.neonCyan.withOpacity(0.3),
                color: AppTheme.neonCyan.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    "KARTI ÇEKMEK İÇİN DOKUN",
                    style: AppTheme.orbitronStyle.copyWith(
                      fontSize: 14,
                      color: AppTheme.neonCyan,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
