import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tekno_mistik/core/services/share_service.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/oracle/presentation/providers/oracle_provider.dart';
import 'package:tekno_mistik/features/oracle/presentation/widgets/pulse_data_icon.dart';

class OracleScreen extends ConsumerStatefulWidget {
  const OracleScreen({super.key});

  @override
  ConsumerState<OracleScreen> createState() => _OracleScreenState();
}

class _OracleScreenState extends ConsumerState<OracleScreen> {
  final _promptController = TextEditingController();
  final _screenshotController = ScreenshotController();

  void _connectToOracle() {
    if (_promptController.text.isNotEmpty) {
      ref.read(oracleNotifierProvider.notifier).seekGuidance(_promptController.text);
    }
  }

  void _reset() {
      _promptController.clear();
      ref.read(oracleNotifierProvider.notifier).reset();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

// ... (imports remain)

  @override
  Widget build(BuildContext context) {
    final oracleState = ref.watch(oracleNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent for LivingBackground
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. The Core (Visual)
              Expanded(
                flex: 2,
                child: Center(
                  child: PulseDataIcon(isThinking: oracleState.isLoading),
                ),
              ),

              // 2. Interaction Area
              Expanded(
                flex: 3,
                child: oracleState.when(
                  data: (response) {
                    if (response == null) {
                      // Input State
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            controller: _promptController,
                            style: GoogleFonts.jetBrainsMono(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Niyetini sisteme gir...",
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                              filled: true,
                              fillColor: AppTheme.surfaceDark.withValues(alpha: 0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppTheme.neonCyan.withValues(alpha: 0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppTheme.neonCyan.withValues(alpha: 0.2)),
                              ),
                            ),
                            maxLines: 3,
                          ).animate().fadeIn().slideY(begin: 0.2),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                _connectToOracle();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.neonCyan.withValues(alpha: 0.1),
                                foregroundColor: AppTheme.neonCyan,
                                side: const BorderSide(color: AppTheme.neonCyan),
                              ),
                              child: const Text("BAĞLANTIYI KUR"),
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      );
                    } else {
                      // Result State
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Screenshot(
                             controller: _screenshotController,
                             child: Container(
                               padding: const EdgeInsets.all(20),
                               decoration: BoxDecoration(
                                 color: AppTheme.deepBlack, // Background for screenshot
                                 borderRadius: BorderRadius.circular(16),
                                 border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
                               ),
                               child: Column(
                                 children: [
                                   Text(
                                     "> ORACLE PROTOKOLÜ",
                                     style: GoogleFonts.orbitron(color: AppTheme.neonPurple, fontSize: 12, letterSpacing: 2),
                                   ),
                                   const SizedBox(height: 20),
                                   Text(
                                     response,
                                     textAlign: TextAlign.center,
                                     style: GoogleFonts.jetBrainsMono(
                                       color: Colors.white,
                                       fontSize: 18,
                                       height: 1.5
                                     ),
                                   ),
                                   const SizedBox(height: 10),
                                   Text("Generated by MysticAI", style: GoogleFonts.orbitron(fontSize: 8, color: Colors.white24)),
                                 ],
                               ),
                             ),
                           ).animate().fadeIn().custom(
                             duration: 2.seconds,
                             builder: (context, value, child) {
                               return child; 
                             },
                           ),
                           const SizedBox(height: 30),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               IconButton(
                                 icon: const Icon(Icons.share, color: AppTheme.neonCyan),
                                 onPressed: () => ShareService.shareWidget(_screenshotController),
                               ),
                               const SizedBox(width: 20),
                               TextButton(
                                 onPressed: _reset,
                                 child: const Text("YENİ BAĞLANTI", style: TextStyle(color: Colors.white54)),
                               ),
                             ],
                           )
                        ],
                      );
                    }
                  },
                  error: (err, stack) => Center(
                    child: Text(
                      "SİNYAL KAYBI: $err",
                      style: const TextStyle(color: AppTheme.errorRed),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  loading: () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                         "VERİLER İŞLENİYOR...",
                         style: GoogleFonts.jetBrainsMono(color: AppTheme.neonCyan),
                       ).animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1.seconds, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
