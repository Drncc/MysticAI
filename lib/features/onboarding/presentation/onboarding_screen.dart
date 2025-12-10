import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:tekno_mistik/features/dashboard/presentation/dashboard_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _onInitialize() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      
      final state = ref.read(onboardingNotifierProvider);
      
      await ref.read(onboardingControllerProvider.notifier).initializeSystem(
        age: state.age!,
        height: state.height!,
        weight: state.weight!,
      );

      if (uploaded && mounted) {
           Navigator.of(context).pushReplacement(
             MaterialPageRoute(builder: (_) => const DashboardScreen()),
           );
      }
    } else {
      HapticFeedback.vibrate();
    }
  }

  bool get isLoading => ref.watch(onboardingControllerProvider).isLoading;
  bool get uploaded => !isLoading && !ref.read(onboardingControllerProvider).hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final controller = ref.watch(onboardingControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Cyberpunk Grid Background Effect (Simplified)
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(color: theme.colorScheme.primary.withValues(alpha: 0.05)),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // Header Glitch Animation
                    Text(
                      "SİSTEM BAŞLATILIYOR...",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 2,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .shimmer(duration: 2.seconds, color: Colors.white)
                     .then(delay: 5.seconds),

                    const SizedBox(height: 20),
                    
                    Text(
                      "BİYOMETRİK\nDOĞRULAMA",
                      style: theme.textTheme.displayLarge,
                    ).animate()
                     .fadeIn(duration: 800.ms)
                     .slideX(begin: -0.2, end: 0, curve: Curves.easeOutExpo),

                     const SizedBox(height: 10),
                     Text(
                       "Somatik veri girişi gereklidir. Bu veriler dijital yansımanızı kalibre etmek için kullanılacaktır.",
                       style: theme.textTheme.bodyMedium,
                     ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 60),

                    // Inputs with terminal aesthetics
                    _buildTerminalInput(
                      controller: _ageController,
                      label: "KRONOLOJİK YAŞ",
                      hint: "Örn: 25",
                      onChanged: notifier.updateAge,
                      theme: theme,
                      delay: 600.ms
                    ),
                    const SizedBox(height: 20),
                    _buildTerminalInput(
                      controller: _heightController,
                      label: "DİKEY UZUNLUK (CM)",
                      hint: "Örn: 175",
                      onChanged: notifier.updateHeight,
                      theme: theme,
                      delay: 800.ms
                    ),
                    const SizedBox(height: 20),
                    _buildTerminalInput(
                      controller: _weightController,
                      label: "KÜTLE (KG)",
                      hint: "Örn: 70",
                      onChanged: notifier.updateWeight,
                      theme: theme,
                      delay: 1000.ms
                    ),

                    const SizedBox(height: 60),

                    // System Initialize Button
                    ElevatedButton(
                      onPressed: (isLoading || !provider.isValid)
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              _onInitialize();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.isValid 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.surface,
                        foregroundColor: provider.isValid 
                            ? Colors.black 
                            : Colors.white.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (ref.watch(onboardingControllerProvider).isLoading)
                             const SizedBox(
                               height: 20, 
                               width: 20, 
                               child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                             )
                          else ...[
                            if (provider.isValid) 
                              const Icon(Icons.power_settings_new, size: 20).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 500.ms),
                            if (provider.isValid) const SizedBox(width: 10),
                            const Text("SİSTEMİ BAŞLAT"),
                          ]
                        ],
                      ),
                    ).animate()
                     .fadeIn(delay: 1200.ms)
                     .scale(duration: 400.ms, curve: Curves.elasticOut),
                     
                     if (ref.watch(onboardingControllerProvider).hasError)
                       Padding(
                         padding: const EdgeInsets.only(top: 20),
                         child: Text(
                           "BAĞLANTI HATASI: ${ref.watch(onboardingControllerProvider).error}",
                           textAlign: TextAlign.center,
                           style: TextStyle(color: theme.colorScheme.error),
                         ).animate().fadeIn(),
                       ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Function(String) onChanged,
    required ThemeData theme,
    required Duration delay,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "> $label",
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
          cursorColor: theme.colorScheme.primary,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: "_ ",
            prefixStyle: TextStyle(color: theme.colorScheme.primary),
            suffixIcon: Icon(Icons.data_array, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'VERİ GİRİŞİ ZORUNLUDUR';
            if (int.tryParse(value) == null) return 'HATALI VERİ TİPİ';
            return null;
          },
        ),
      ],
    ).animate().fadeIn(delay: delay).slideY(begin: 0.2, end: 0);
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Vertical lines
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Horizontal lines
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
