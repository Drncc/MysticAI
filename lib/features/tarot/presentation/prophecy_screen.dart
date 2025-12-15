import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/core/theme/app_text_styles.dart';
import 'package:tekno_mistik/features/tarot/presentation/widgets/mystic_tarot_card.dart';
import 'package:tekno_mistik/features/tarot/services/tarot_service.dart';
import 'package:tekno_mistik/core/services/limit_service.dart';
import 'package:tekno_mistik/core/i18n/app_localizations.dart';

class ProphecyScreen extends ConsumerStatefulWidget {
  const ProphecyScreen({super.key});

  @override
  ConsumerState<ProphecyScreen> createState() => _ProphecyScreenState();
}

class _ProphecyScreenState extends ConsumerState<ProphecyScreen> {
  bool _isSealing = false; // Loading state

  Future<void> _revealProphecy() async {
    if (!LimitService().canDrawCard) {
      _showLimitDialog();
      return;
    }

    // 1. Loading Ritual Start
    setState(() {
      _isSealing = true;
    });

    // 3 Saniye Bekle (Mistik Gerilim)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final random = Random();
    int preferredVariant = 1; 
    if (random.nextDouble() > 0.7) preferredVariant = 3; 

    final selection = await TarotService().drawDailyCard(preferredVariant: preferredVariant);
    
    LimitService().incrementCard();

    setState(() {
      _isSealing = false; // Loading bitti
    });

    if (!mounted) return;

    _showResultDialog(selection);
  }

  void _showLimitDialog() {
    final tr = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text(tr.translate('prophecy_limit_title'), style: AppTextStyles.h3.copyWith(color: AppTheme.errorRed)),
        content: Text(tr.translate('prophecy_limit_msg'), style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            child: Text(tr.translate('btn_understood'), style: const TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(TarotSelection selection) {
    final tr = AppLocalizations.of(context);
    // Dynamic localization based on card codeName
    final cardName = tr.translate('tarot_${selection.card.codeName}_name');
    final cardMeaning = tr.translate('tarot_${selection.card.codeName}_desc');

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
                       tr.translate('prophecy_result_title'), 
                       style: AppTextStyles.h2.copyWith(color: AppTheme.neonCyan, shadows: [Shadow(color: AppTheme.neonCyan, blurRadius: 15)]),
                       textAlign: TextAlign.center,
                     ),
                     const SizedBox(height: 30),
                     
                     // KART GÖRSELİ
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
                     
                     Padding(
                       padding: const EdgeInsets.only(bottom: 10.0),
                       child: Text(
                         cardName.toUpperCase(),
                         style: AppTextStyles.h3.copyWith(color: Colors.amber),
                       ),
                     ),
                     
                     Text(
                       "\"$cardMeaning\"", 
                       textAlign: TextAlign.center,
                       style: GoogleFonts.crimsonText( 
                         color: Colors.white.withOpacity(0.95),
                         fontSize: 22,
                         fontStyle: FontStyle.italic,
                         height: 1.4
                       ),
                     ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                     
                     const SizedBox(height: 30),
                     
                     // PAYLAŞ BUTONU
                     SizedBox(
                       width: double.infinity,
                       child: ElevatedButton.icon(
                         style: ElevatedButton.styleFrom(
                           backgroundColor: AppTheme.neonPurple,
                           padding: const EdgeInsets.symmetric(vertical: 12),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                         ),
                         icon: const Icon(Icons.share, color: Colors.white),
                         label: Text(tr.translate('prophecy_share_btn'), style: AppTextStyles.button.copyWith(color: Colors.white)),
                         onPressed: () {
                           Share.share('Mistik AI: $cardName - $cardMeaning 🔮✨');
                         },
                       ),
                     ),
                     const SizedBox(height: 15),
                     
                     GestureDetector(
                       onTap: () => Navigator.of(context).pop(),
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                         child: Text(tr.translate('prophecy_close_btn'), style: AppTextStyles.bodySmall.copyWith(letterSpacing: 2)),
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
    final tr = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(tr.translate('prophecy_title'), style: AppTextStyles.h2.copyWith(letterSpacing: 2)),
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
                onTap: _isSealing ? null : _revealProphecy, 
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
                        Image.asset(
                          'assets/tarot/card_back.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF151026),
                            child: const Center(child: Icon(Icons.help_outline, color: Colors.white24, size: 50)),
                          ),
                        ),
                        Container(color: Colors.black.withOpacity(0.2)),
                        
                        // ANIMASYON (Yükleniyor vs Normal)
                        if (_isSealing)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(color: AppTheme.neonPurple),
                                const SizedBox(height: 20),
                                Text(tr.translate('prophecy_seal_btn'), style: AppTextStyles.button.copyWith(color: Colors.white70))
                                    .animate(onPlay: (c)=>c.repeat()).fadeIn(duration: 500.ms)
                              ],
                            ),
                          )
                        else
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
                 .moveY(end: -15, duration: 3.seconds, curve: Curves.easeInOut), 
              ),

              const SizedBox(height: 40),

              GlassCard(
                borderColor: AppTheme.neonCyan.withOpacity(0.3),
                color: AppTheme.neonCyan.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    _isSealing ? tr.translate('prophecy_listening') : tr.translate('prophecy_seal_action'),
                    style: AppTextStyles.button.copyWith(color: AppTheme.neonCyan),
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
