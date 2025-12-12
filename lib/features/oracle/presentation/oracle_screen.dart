import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/oracle/presentation/providers/oracle_provider.dart';
import 'package:tekno_mistik/features/oracle/presentation/widgets/complex_sigil.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/user_settings_provider.dart';

class OracleScreen extends ConsumerStatefulWidget {
  const OracleScreen({super.key});

  @override
  ConsumerState<OracleScreen> createState() => _OracleScreenState();
}

class _OracleScreenState extends ConsumerState<OracleScreen> {
  final TextEditingController _promptController = TextEditingController();
  String? _lastQuestion; // To track the question for saving

  void _sendMessage() {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    final userSettings = ref.read(userSettingsProvider);

    // Bağlam Zenginleştirme
    String contextPrompt = "\n[GİZLİ BAĞLAM: Kullanıcı Adı: ${userSettings.name}. ";
    if (userSettings.age.isNotEmpty) contextPrompt += "Yaş: ${userSettings.age}. ";
    if (userSettings.profession.isNotEmpty) contextPrompt += "Meslek: ${userSettings.profession}. ";
    if (userSettings.maritalStatus.isNotEmpty) contextPrompt += "Medeni Durum: ${userSettings.maritalStatus}. ";
    if (userSettings.includeZodiacInOracle) contextPrompt += "Burç: ${userSettings.zodiacSign}. Astrolojik referanslar kullan. ";
    contextPrompt += "]";

    final String finalPrompt = "$text $contextPrompt";

    // Soruyu kaydet (Cevap gelince eşleştirmek için)
    setState(() {
      _lastQuestion = text;
    });

    _promptController.clear();
    FocusScope.of(context).unfocus();
    ref.read(oracleNotifierProvider.notifier).seekGuidance(finalPrompt, isPremium: false);
  }

  Future<void> _saveToHistory(String question, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentHistory = prefs.getStringList('oracle_chat_history') ?? [];

    final Map<String, String> newEntry = {
      'question': question,
      'answer': answer, // Cevabı olduğu gibi veya kısaltarak
      'date': DateTime.now().toIso8601String(),
    };

    currentHistory.insert(0, jsonEncode(newEntry));
    await prefs.setStringList('oracle_chat_history', currentHistory); 
  }

  @override
  Widget build(BuildContext context) {
    final oracleState = ref.watch(oracleNotifierProvider);

    // Listen to state changes to capture the response
    ref.listen(oracleNotifierProvider, (previous, next) {
      if (next is AsyncData && next.value != null && _lastQuestion != null) {
        // Cevap geldi, kaydet
        _saveToHistory(_lastQuestion!, next.value!);
        _lastQuestion = null; // Reset
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("ORACLE", style: AppTheme.orbitronStyle.copyWith(letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. SIGIL (Oracle's Eye)
          Expanded(
            flex: 4,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Container(
                     width: 180, height: 180,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       boxShadow: [
                         BoxShadow(color: AppTheme.neonPurple.withOpacity(0.4), blurRadius: 60, spreadRadius: 10),
                         BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 90, spreadRadius: 20),
                       ]
                     ),
                   ),
                   const TheComplexSigil(size: 200),
                ],
              ),
            ),
          ),

          // 2. RESPONSE AREA
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: oracleState.when(
                data: (response) {
                  return GlassCard(
                    borderColor: AppTheme.neonPurple.withOpacity(0.3),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(minHeight: 150),
                      child: SingleChildScrollView(
                        child: Text(
                          response ?? "Kehanet için sorunu yönelt...",
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9), 
                            height: 1.6, 
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1);
                },
                error: (err, _) => Center(child: Text("Hata: $err", style: TextStyle(color: AppTheme.errorRed))),
                loading: () => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "EVRENSEL VERİLER TOPLANIYOR...",
                        style: AppTheme.orbitronStyle.copyWith(color: AppTheme.neonCyan, fontSize: 12),
                        textAlign: TextAlign.center,
                      ).animate(onPlay: (c)=>c.repeat(reverse: true)).fadeIn(duration: 500.ms),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(color: AppTheme.neonCyan, backgroundColor: Colors.white10),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. INPUT AREA
          Padding(
            padding: const EdgeInsets.only(
              bottom: 90.0, // Safe padding for BottomNav
              left: 16, 
              right: 16, 
              top: 10
            ),
            child: GlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: AppTheme.neonCyan,
                      decoration: InputDecoration(
                        hintText: "Sorunu Yaz...",
                        hintStyle: TextStyle(color: Colors.white30, fontFamily: 'Inter'),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send_rounded, color: AppTheme.neonPurple),
                    onPressed: _sendMessage,
                  ).animate().scale(delay: 200.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
