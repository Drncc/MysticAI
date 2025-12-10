import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/history_provider.dart';
import 'package:tekno_mistik/core/utils/zodiac_calculator.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _bioMetrics = {};
  
  // Cosmic Data
  DateTime? _birthDate;
  String _zodiacSign = "";
  bool _cosmicEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        final bio = data['bio_metrics'] as Map<String, dynamic>? ?? {};
        setState(() {
          _bioMetrics = bio;
          
          if (bio['birth_date'] != null) {
            _birthDate = DateTime.tryParse(bio['birth_date']);
            if (_birthDate != null) {
              _zodiacSign = getZodiacSign(_birthDate!);
            }
          }
          _cosmicEnabled = bio['cosmic_enabled'] ?? false;
        });
      }
    } catch (e) {
      debugPrint("Profile Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCosmicData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final updatedBio = Map<String, dynamic>.from(_bioMetrics);
      if (_birthDate != null) {
        updatedBio['birth_date'] = _birthDate!.toIso8601String();
        updatedBio['zodiac_sign'] = _zodiacSign;
      }
      updatedBio['cosmic_enabled'] = _cosmicEnabled;

      await Supabase.instance.client.from('profiles').update({
        'bio_metrics': updatedBio,
      }).eq('id', userId);

      setState(() {
        _bioMetrics = updatedBio;
      });

      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Kozmik Veriler Güncellendi"), backgroundColor: AppTheme.neonCyan),
         );
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Hata: $e"), backgroundColor: AppTheme.errorRed),
         );
       }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonPurple,
              onPrimary: Colors.white,
              surface: AppTheme.deepBlack,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _zodiacSign = getZodiacSign(picked);
      });
      _saveCosmicData(); // Auto save on change
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyNotifierProvider);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: AppTheme.neonCyan)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
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

              // COSMIC DATA CARD (NEW)
              GlassCard(
                borderColor: AppTheme.neonPurple.withValues(alpha: 0.5),
                child: Column(
                  children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text("KOZMİK ANALİZ", style: GoogleFonts.orbitron(color: AppTheme.neonPurple, fontSize: 12)),
                         Switch(
                           value: _cosmicEnabled,
                           activeColor: AppTheme.neonPurple,
                           onChanged: (val) {
                             setState(() => _cosmicEnabled = val);
                             _saveCosmicData();
                           },
                         )
                       ],
                     ),
                     const Divider(color: Colors.white12),
                     GestureDetector(
                       onTap: () => _selectDate(context),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text("DOĞUM TARİHİ", style: TextStyle(color: Colors.white38, fontSize: 10)),
                               Text(
                                 _birthDate == null 
                                   ? "Seçilmedi" 
                                   : "${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}",
                                 style: const TextStyle(color: Colors.white, fontSize: 16),
                               ),
                             ],
                           ),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               const Text("BURÇ", style: TextStyle(color: Colors.white38, fontSize: 10)),
                               Text(
                                 _zodiacSign.isEmpty ? "--" : _zodiacSign,
                                 style: const TextStyle(color: AppTheme.neonCyan, fontSize: 16, fontWeight: FontWeight.bold),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms),

              const SizedBox(height: 20),

              // Biometrics Section (Read Only here, updated in onboarding)
              GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBioItem("YAŞ", _bioMetrics['age']?.toString() ?? "--"),
                    _buildBioItem("BOY", "${_bioMetrics['height'] ?? '--'} cm"),
                    _buildBioItem("KÜTLE", "${_bioMetrics['weight'] ?? '--'} kg"),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms),

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

              const SizedBox(height: 10),
              
              // System Control
              GlassCard(
                borderColor: AppTheme.errorRed.withValues(alpha: 0.5),
                child: InkWell(
                  onTap: () async {
                    await HapticFeedback.mediumImpact();
                    await Supabase.instance.client.auth.signOut();
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
