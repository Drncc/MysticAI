import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/core/theme/app_text_styles.dart';
import 'package:tekno_mistik/features/oracle/presentation/providers/oracle_provider.dart';
import 'package:tekno_mistik/features/oracle/presentation/widgets/complex_sigil.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/user_settings_provider.dart';
import 'package:tekno_mistik/core/services/limit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekno_mistik/core/i18n/app_localizations.dart';
import 'package:tekno_mistik/features/oracle/models/chat_message.dart';
import 'package:tekno_mistik/core/services/oracle_service.dart';

class OracleScreen extends ConsumerStatefulWidget {
  const OracleScreen({super.key});

  @override
  ConsumerState<OracleScreen> createState() => _OracleScreenState();
}

class _OracleScreenState extends ConsumerState<OracleScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OracleService _oracleService = OracleService();
  
  // State
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  


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
  }



  Future<void> _sendMessage({String? suggestion}) async {
    final text = suggestion ?? _promptController.text.trim();
    if (text.isEmpty) return;

    if (!LimitService().canAskOracle) {
      _showLimitDialog();
      return;
    }


    FocusScope.of(context).unfocus();
    _promptController.clear();

    // 1. Add User Message
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    final tr = AppLocalizations.of(context);
    final languageCode = tr.locale.languageCode;

    // 2. Call API
    final response = await _oracleService.getOracleChatGuidance(
      _messages, 
      languageCode
    );

    // 3. Add AI Response
    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
      
      // Auto-Speak if enabled (optional, currently disabled by default logic but structure remains)
      // if (_isVoiceEnabled) _speak(response);
    }
    
    // 4. Increment Limit
    LimitService().incrementOracle();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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

  @override
  Widget build(BuildContext context) {
    // Note: We no longer watch oracleNotifierProvider for response text, 
    // as we manage chat state locally.
    final tr = AppLocalizations.of(context);
    final suggestions = _getSuggestions(tr);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(tr.translate('nav_oracle'), style: AppTextStyles.h2.copyWith(letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [],
      ),
      body: Column(
        children: [
          // 1. SMALL SIGIL (Reduced Flex)
          Expanded(
            flex: 2,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                   if (_isLoading)
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.neonCyan.withOpacity(0.1)),
                    ).animate(onPlay: (c)=>c.repeat(reverse: true))
                     .scaleXY(end: 1.3, duration: 800.ms)
                     .fade(end: 0),
                   const TheComplexSigil(size: 100),
                ],
              ),
            ),
          ),

          // 2. CHAT AREA (Increased Flex)
          Expanded(
            flex: 6,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _messages.isEmpty && !_isLoading
                  ? Center(
                      child: Text(
                        tr.translate('oracle_placeholder'), 
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54, fontStyle: FontStyle.italic),
                      ).animate().fadeIn(),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      padding: const EdgeInsets.only(bottom: 100),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                           // Loading indicator bubble
                           return Align(
                             alignment: Alignment.centerLeft,
                             child: Container(
                               margin: const EdgeInsets.symmetric(vertical: 4),
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: AppTheme.neonPurple.withOpacity(0.1),
                                 borderRadius: const BorderRadius.only(
                                   topLeft: Radius.circular(0),
                                   topRight: Radius.circular(16),
                                   bottomLeft: Radius.circular(16),
                                   bottomRight: Radius.circular(16),
                                 ),
                                 border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
                               ),
                               child: SizedBox(
                                 width: 24, height: 24,
                                 child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.neonCyan)
                               ),
                             ).animate().fadeIn(),
                           );
                        }

                        final msg = _messages[index];
                        return _buildChatBubble(msg);
                      },
              ),
            ),
          ),

          // 3. INPUT AREA
          Padding(
            padding: const EdgeInsets.only(bottom: 90.0, left: 16, right: 16, top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_messages.isEmpty) // Show chips only if chat hasn't started deep scroll
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

  Widget _buildChatBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 16 : 0),
            topRight: Radius.circular(isUser ? 0 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          border: isUser 
              ? null 
              : Border.all(color: AppTheme.neonCyan.withOpacity(0.5), width: 1),
          boxShadow: isUser 
              ? [] 
              : [BoxShadow(color: AppTheme.neonCyan.withOpacity(0.1), blurRadius: 8, spreadRadius: 1)],
        ),
        child: Text(
          msg.text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            height: 1.4,
            fontFamily: isUser ? null : 'Cinzel', // Mystical font for Oracle
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms),
    );
  }
}
