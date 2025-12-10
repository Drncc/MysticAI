import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/onboarding/controllers/onboarding_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final neon = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppTheme.deepBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistem Başlatılıyor',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: neon,
                        letterSpacing: 1.2,
                      ),
                ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: 12),
                Text(
                  'Biyo-dijital parametreler toplanıyor. Algoritmik akış için kendini tanımla.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(duration: 450.ms, curve: Curves.easeOut),
                const SizedBox(height: 24),

                // Step 1: Name
                _GlitchCard(
                  title: 'Birim Kimliği',
                  subtitle: 'Identify Biological Unit',
                  child: TextField(
                    onChanged: (v) =>
                        ref.read(onboardingControllerProvider.notifier).setName(v),
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'İsim / Kod Adı',
                      hintText: 'Örnek: Kuantum Gezgin',
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, curve: Curves.easeOut),
                const SizedBox(height: 16),

                // Step 2: Age & Height
                _GlitchCard(
                  title: 'Biyo-Metrik Vektörler',
                  subtitle: 'Input Temporal Cycles & Vertical Metric',
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (v) => ref
                              .read(onboardingControllerProvider.notifier)
                              .setAge(int.tryParse(v)),
                          decoration: const InputDecoration(
                            labelText: 'Yaş',
                            hintText: 'Temporal Cycles',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (v) => ref
                              .read(onboardingControllerProvider.notifier)
                              .setHeight(int.tryParse(v)),
                          decoration: const InputDecoration(
                            labelText: 'Boy (cm)',
                            hintText: 'Vertical Metric',
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 550.ms, curve: Curves.easeOut),
                const SizedBox(height: 16),

                // Step 3: Astrology toggle
                _GlitchCard(
                  title: 'Kozmik Veri Bağı',
                  subtitle: 'Enable Cosmic Data Link?',
                  child: SwitchListTile(
                    value: state.isAstrologyEnabled,
                    onChanged: (v) => ref
                        .read(onboardingControllerProvider.notifier)
                        .toggleAstrology(v),
                    title: const Text('Kozmik hizalanma sinyallerini işleme'),
                    subtitle: const Text(
                        'Entropi ve rezonans analizi için ek veri vektörleri'),
                    activeColor: neon,
                    contentPadding: EdgeInsets.zero,
                  ),
                ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut),
                const SizedBox(height: 24),

                // Step 4: Initialize button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final errors = _validate(state);
                      if (errors.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errors.join('\n'))),
                        );
                        return;
                      }
                      context.go('/dashboard');
                    },
                    child: const Text('Sistemi Başlat'),
                  ),
                ).animate().fadeIn(duration: 650.ms, curve: Curves.easeOut),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _validate(OnboardingState state) {
    final errors = <String>[];
    if (state.name.isEmpty) {
      errors.add('Birim kimliği gerekli.');
    }
    if (state.age == null || state.age! <= 0) {
      errors.add('Temporal cycle (yaş) geçerli değil.');
    }
    if (state.height == null || state.height! <= 0) {
      errors.add('Vertical metric (boy) geçerli değil.');
    }
    return errors;
  }
}

class _GlitchCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _GlitchCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.darkGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.neonPurpleDark, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.neonPurpleLight,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

