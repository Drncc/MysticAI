import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/core/theme/app_text_styles.dart';
import 'package:tekno_mistik/features/oracle/presentation/providers/oracle_provider.dart';
import 'package:tekno_mistik/features/oracle/presentation/widgets/complex_sigil.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/user_settings_provider.dart';
import 'package:tekno_mistik/core/services/limit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekno_mistik/core/i18n/app_localizations.dart';

class OracleScreen extends ConsumerStatefulWidget {
  const OracleScreen({super.key});

  @override
  ConsumerState<OracleScreen> createState() => _OracleScreenState();
}

class _OracleScreenState extends ConsumerState<OracleScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _lastQuestion;
  
  // TTS & Voice
  late FlutterTts _flutterTts;
  bool _isVoiceEnabled = false;
  bool _isSpeaking = false;

  final List<String> _suggestions = [
    "Bugün enerjim nasıl?",
    "Aşk hayatımda neler olacak?",
    "Kariyerimde yükseliş var mı?",
    "Rüyamda yılan gördüm, anlamı ne?",
    "Hangi çakram tıkalı?",
    "Ruh eşimle ne zaman tanışacağım?"
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    
    // Voice Characteristics
    _flutterTts.setPitch(0.6); // Mistik/Kalın
    _flutterTts.setSpeechRate(0.4); // Yavaş/Tane tane
    
    // Handlers
    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
    
    _flutterTts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
    });
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _speak(String text) async {
    if (!_isVoiceEnabled) return;
    await _flutterTts.stop();
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  void _backgroundImage() {} // Empty function removed

  void _sendMessage({String? suggestion}) {
    final text = suggestion ?? _promptController.text.trim();
    if (text.isEmpty) return;

    if (!LimitService().canSendMessage) {
      _showLimitDialog();
      return;
    }

    // Stop speaking if new message sent
    _flutterTts.stop();

    final userSettings = ref.read(userSettingsProvider);
    final tr = AppLocalizations.of(context);
    final isEn = tr.locale.languageCode == 'en';

    String contextPrompt;
    if (isEn) {
      contextPrompt = "\n[HIDDEN CONTEXT: Username: ${userSettings.name}. ";
      if (userSettings.age.isNotEmpty) contextPrompt += "Age: ${userSettings.age}. ";
      if (userSettings.profession.isNotEmpty) contextPrompt += "Profession: ${userSettings.profession}. ";
      if (userSettings.maritalStatus.isNotEmpty) contextPrompt += "Marital Status: ${userSettings.maritalStatus}. ";
      if (userSettings.includeZodiacInOracle) contextPrompt += "Zodiac: ${userSettings.zodiacSign}. Use astrological references. ";
      
      contextPrompt += "You are not just a bot answering questions, you are a curious friend wanting to continue the conversation. AFTER your answer, YOU MUST ASK a new, personal, and intriguing question related to the topic. Never close the topic.";
      contextPrompt += " RESPONSE LANGUAGE RULE: Response MUST be in English. Do not mix other languages.]";
      
      if (LimitService().isPremium) {
        contextPrompt += " Give a detailed, long answer including astrological transits.";
      } else {
        contextPrompt += " Keep the answer mystical and short (2-3 sentences).";
      }
    } else {
      contextPrompt = "\n[GİZLİ BAĞLAM: Kullanıcı Adı: ${userSettings.name}. ";
      if (userSettings.age.isNotEmpty) contextPrompt += "Yaş: ${userSettings.age}. ";
      if (userSettings.profession.isNotEmpty) contextPrompt += "Meslek: ${userSettings.profession}. ";
      if (userSettings.maritalStatus.isNotEmpty) contextPrompt += "Medeni Durum: ${userSettings.maritalStatus}. ";
      if (userSettings.includeZodiacInOracle) contextPrompt += "Burç: ${userSettings.zodiacSign}. Astrolojik referanslar kullan. ";
      
      contextPrompt += "Sen sadece cevap veren bir bot değil, sohbeti devam ettirmek isteyen meraklı bir arkadaşsın. Cevabını verdikten sonra MUTLAKA kullanıcıya konuyla ilgili yeni, kişisel ve merak uyandırıcı bir soru sor. Konuyu asla kapatma.";
      contextPrompt += " YANIT DİLİ KURALI: Yanıtlarını SADECE standart Türkçe alfabesi ile ver. Asla Çince, Japonca, Kiril veya Latin olmayan başka karakterler kullanma. Kelimelerin arasına yabancı semboller karıştırma.]";
      
      if (LimitService().isPremium) {
        contextPrompt += " Cevabı detaylı, astrolojik transitleri içerecek şekilde uzun ver.";
      } else {
        contextPrompt += " Cevabı 2-3 cümle ile mistik ve kısa tut.";
      }
    }

    final String finalPrompt = "$text $contextPrompt";

    setState(() {
      _lastQuestion = text;
    });

    _promptController.clear();
    FocusScope.of(context).unfocus();
    LimitService().incrementMessage();
    
    ref.read(oracleNotifierProvider.notifier).seekGuidance(
      finalPrompt, 
      tr.locale.languageCode, 
      isPremium: LimitService().isPremium
    );
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text("Enerjin Tükendi", style: AppTextStyles.h3.copyWith(color: AppTheme.errorRed)),
        content: Text("Gezgin, günlük kozmik soru hakkını doldurdun. Kahin seviyesine yükselerek sınırları kaldır.", style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            child: const Text("KAPAT", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToHistory(String question, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentHistory = prefs.getStringList('oracle_chat_history') ?? [];
    final Map<String, String> newEntry = {
      'question': question,
      'answer': answer,
      'date': DateTime.now().toIso8601String(),
    };
    currentHistory.insert(0, jsonEncode(newEntry));
    await prefs.setStringList('oracle_chat_history', currentHistory); 
  }

  @override
  Widget build(BuildContext context) {
    final oracleState = ref.watch(oracleNotifierProvider);

    ref.listen(oracleNotifierProvider, (previous, next) {
      if (next is AsyncData && next.value != null && _lastQuestion != null) {
        _saveToHistory(_lastQuestion!, next.value!);
        _lastQuestion = null;
        HapticFeedback.lightImpact();
        
        // Speak Response
        _speak(next.value!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("ORACLE", style: AppTextStyles.h2.copyWith(letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isVoiceEnabled ? Icons.volume_up : Icons.volume_off, 
              color: _isVoiceEnabled ? AppTheme.neonCyan : Colors.white24
            ),
            onPressed: () {
              setState(() {
                _isVoiceEnabled = !_isVoiceEnabled;
                if (!_isVoiceEnabled) _flutterTts.stop();
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. SIGIL
          Expanded(
            flex: 4,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Pulse Effect Container when speaking
                   if (_isSpeaking)
                    Container(
                      width: 220, height: 220,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.neonCyan.withOpacity(0.1)),
                    ).animate(onPlay: (c)=>c.repeat(reverse: true))
                     .scaleXY(end: 1.3, duration: 800.ms)
                     .fade(end: 0),

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
                        controller: _scrollController,
                        child: Text(
                          response ?? "Kehanet için sorunu yönelt...",
                          style: AppTextStyles.bodyLarge,
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
                        style: AppTextStyles.button.copyWith(color: AppTheme.neonCyan, fontSize: 12),
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

          // 3. INPUT & SUGGESTIONS AREA
          Padding(
            padding: const EdgeInsets.only(bottom: 90.0, left: 16, right: 16, top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!oracleState.isLoading)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            side: BorderSide(color: AppTheme.neonCyan.withOpacity(0.3)),
                            label: Text(_suggestions[index], style: AppTextStyles.bodySmall.copyWith(color: AppTheme.neonCyan)),
                            onPressed: () => _sendMessage(suggestion: _suggestions[index]),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                GlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promptController,
                          style: AppTextStyles.bodyMedium,
                          cursorColor: AppTheme.neonCyan,
                          decoration: InputDecoration(
                            hintText: "Sorunu Yaz...",
                            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white30),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send_rounded, color: AppTheme.neonPurple),
                        onPressed: () => _sendMessage(),
                      ).animate().scale(delay: 200.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
