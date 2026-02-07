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

  List<String> _getSuggestions(AppLocalizations tr) {
    return [
      tr.translate('chip_energy'),
      tr.translate('chip_love'),
      tr.translate('chip_career'),
      tr.translate('chip_dream'),
      tr.translate('chip_chakra'),
      tr.translate('chip_soulmate')
    ];
  }

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    _flutterTts = FlutterTts();

    // Set Language dynamically based on current Locale
    // We can't access context in initState directly easily for InheritedWidgets unless we do it in didChangeDependencies
    // But we can get the current locale from the Riverpod provider since we are in a ConsumerState
    final currentLocale = ref.read(localeProvider);
    final ttsLang = currentLocale.languageCode == 'tr' ? "tr-TR" : "en-US";
    
    await _flutterTts.setLanguage(ttsLang);
    await _flutterTts.setPitch(0.6); // Mistik/Kalın
    await _flutterTts.setSpeechRate(0.4); // Yavaş/Tane tane
    
    // Handlers
    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    
    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  void _sendMessage({String? suggestion}) {
    final text = suggestion ?? _promptController.text.trim();
    if (text.isEmpty) return;

    if (!LimitService().canAskOracle) {
      _showLimitDialog();
      return;
    }

    _flutterTts.stop();

    final tr = AppLocalizations.of(context);
    final languageCode = tr.locale.languageCode;

    FocusScope.of(context).unfocus();
    _promptController.clear();

    ref.read(oracleNotifierProvider.notifier).seekGuidance(text, languageCode);
    
    LimitService().incrementOracle();
  }

  void _showLimitDialog() {
    final tr = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text(tr.translate('oracle_limit_title'), style: AppTextStyles.h3.copyWith(color: AppTheme.errorRed)),
        content: Text(tr.translate('oracle_limit_msg'), style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            child: Text(tr.translate('btn_understood'), style: const TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

// ...

  @override
  Widget build(BuildContext context) {
    final oracleState = ref.watch(oracleNotifierProvider);
    final tr = AppLocalizations.of(context);
    final suggestions = _getSuggestions(tr);

    // ... (Listener kept same)

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(tr.translate('nav_oracle'), style: AppTextStyles.h2.copyWith(letterSpacing: 2)), // Using nav_oracle ("ORACLE")
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
            // ... (Voice button kept same)
        ],
      ),
      body: Column(
        children: [
          // 1. SIGIL
          // ... (Sigil kept same)
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
                          response ?? tr.translate('oracle_placeholder'),
                          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, height: 1.5),
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
                        "EVRENSEL VERİLER TOPLANIYOR...", // Consider localizing this too if time permits
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
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            side: BorderSide(color: AppTheme.neonCyan.withOpacity(0.3)),
                            label: Text(suggestions[index], style: AppTextStyles.bodySmall.copyWith(color: AppTheme.neonCyan)),
                            onPressed: () => _sendMessage(suggestion: suggestions[index]),
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
                            hintText: tr.translate('input_hint'),
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
