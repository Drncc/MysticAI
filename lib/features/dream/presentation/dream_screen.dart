import 'package:flutter/material.dart';

import 'dart:io'; // Platform kontrolü
import 'package:tekno_mistik/core/services/oracle_service.dart';
import 'package:tekno_mistik/core/i18n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';

class DreamScreen extends StatefulWidget {
  const DreamScreen({super.key});

  @override
  State<DreamScreen> createState() => _DreamScreenState();
}

class _DreamScreenState extends State<DreamScreen> {
  final TextEditingController _controller = TextEditingController();
  // TTS REMOVED
  
  bool isAnalyzing = false;
  String? resultText;
  
  @override
  void initState() {
    super.initState();
    // _initTts(); // REMOVED
  }

  // _initTts removed


  void _analyzeDream() async {
    if (_controller.text.isEmpty) return;
    
    final tr = AppLocalizations.of(context);
    final languageCode = tr.locale.languageCode;
    
    // Set TTS Language - REMOVED

    FocusScope.of(context).unfocus();

    setState(() {
      isAnalyzing = true;
      resultText = null;
    });

    // Real API Call
    try {
      final analysis = await OracleService().analyzeDream(_controller.text, languageCode);
      
      if (mounted) {
        setState(() {
          isAnalyzing = false;
          resultText = analysis;
        });
        // _speak(analysis); // REMOVED
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isAnalyzing = false;
          resultText = languageCode == 'en' ? "Connection interrupted with the dream realm." : "Rüya alemiyle bağlantı koptu.";
        });
      }
    }
  }

  // speak method removed


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(tr.translate('dream_title'), style: AppTextStyles.orbitronStyle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.purpleAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              tr.translate('dream_subtitle'),
              textAlign: TextAlign.center,
              style: AppTextStyles.interStyle.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 30),

            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: tr.translate('dream_hint'),
                  hintStyle: const TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            if (!isAnalyzing && resultText == null)
              ElevatedButton(
                onPressed: _analyzeDream,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(tr.translate('btn_decode_symbols'), style: AppTextStyles.orbitronStyle),
              ),

            if (isAnalyzing)
              const CircularProgressIndicator(color: Colors.purpleAccent),

            if (resultText != null)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text("KOZMİK YANSIMA", style: AppTextStyles.orbitronStyle.copyWith(fontSize: 12, color: Colors.cyanAccent)),
                    const SizedBox(height: 10),
                    Text(
                      resultText!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.interStyle.copyWith(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 10),
                    // TTS Button REMOVED
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
