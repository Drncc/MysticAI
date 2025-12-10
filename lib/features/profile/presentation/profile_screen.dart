import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/history_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyNotifierProvider);
    
    // Fetch user profile data locally or from Supabase (for simplicity, using a FutureBuilder here for biometrics)
    // Ideally this should also be in a provider.
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppTheme.deepBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                "NÖRAL ARŞİV",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
              ).animate().fadeIn().slideX(),
              
              const SizedBox(height: 20),

              // Biometrics Section (FutureBuilder for single fetch)
              FutureBuilder(
                future: Supabase.instance.client.from('profiles').select().eq('id', userId!).single(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data as Map<String, dynamic>;
                    final bio = data['bio_metrics'] ?? {};
                    return GlassCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBioItem("YAŞ", bio['age']?.toString() ?? "--"),
                          _buildBioItem("BOY", "${bio['height'] ?? '--'} cm"),
                          _buildBioItem("KÜTLE", "${bio['weight'] ?? '--'} kg"),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms);
                  }
                  return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppTheme.neonCyan)));
                },
              ),

              const SizedBox(height: 30),
              
              // History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("GEÇMİŞ KEHANETLER", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.neonPurple)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white54),
                    onPressed: () => ref.refresh(historyNotifierProvider),
                  )
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: historyAsync.when(
                  data: (history) {
                    if (history.isEmpty) {
                      return Center(
                        child: Text(
                          "Arşiv boş. Henüz bir kehanet indirilmedi.",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final prompt = item['prompt'] as String;
                        final response = item['response'] as String;
                        final date = DateTime.parse(item['created_at']).toLocal();

                        return GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tarih: ${date.day}/${date.month} ${date.hour}:${date.minute}",
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "> $prompt",
                                style: GoogleFonts.jetBrainsMono(color: AppTheme.neonCyan, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                response,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
                      },
                    );
                  },
                  error: (err, stack) => Center(child: Text("Arşiv Hatası: $err", style: const TextStyle(color: AppTheme.errorRed))),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonPurple)),
                ),
              ),

              const SizedBox(height: 20),
              
              // System Control
              Text("SİSTEM KONTROLÜ", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.errorRed)),
              const SizedBox(height: 10),
              GlassCard(
                borderColor: AppTheme.errorRed.withValues(alpha: 0.5),
                child: InkWell(
                  onTap: () async {
                    // Haptic Feedback
                    await HapticFeedback.mediumImpact();
                    
                    // Logout Logic
                    await Supabase.instance.client.auth.signOut();
                    
                    // Navigate to Onboarding (Hard Reset)
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Icon(Icons.power_settings_new, color: AppTheme.errorRed),
                       const SizedBox(width: 10),
                       Text("OTURUMU SONLANDIR", style: GoogleFonts.orbitron(color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                 child: Text(
                   "Sürüm v1.0 (BETA) // TEKNO_MISTIK",
                   style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 10),
                 ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBioItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }
}
