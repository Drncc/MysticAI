import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io'; // Platform kontrolü
import '../../../../core/theme/app_text_styles.dart';

class DreamScreen extends StatefulWidget {
  const DreamScreen({super.key});

  @override
  State<DreamScreen> createState() => _DreamScreenState();
}

class _DreamScreenState extends State<DreamScreen> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  
  bool isAnalyzing = false;
  String? resultText;
  
  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    // 1. Dili Türkçe yapmaya zorla
    await flutterTts.setLanguage("tr-TR");
    
    // 2. Platforma göre hız ayarı (Windows Hassas Ayar)
    if (Platform.isWindows) {
      // Windows'ta 1.0 standart hızdır. Bunun altı bazen hecelemeye döner.
      await flutterTts.setSpeechRate(1.0); 
      await flutterTts.setPitch(1.0); // Doğal ton
    } else {
      // Mobilde biraz daha yavaş ve mistik olabilir
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setPitch(0.8);
    }
    
    await flutterTts.setVolume(1.0);
  }

  void _analyzeDream() async {
    if (_controller.text.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      isAnalyzing = true;
      resultText = null;
    });

    // Analiz simülasyonu
    await Future.delayed(const Duration(seconds: 2));

    String analysis = "Gördüğün bu rüya, iç dünyandaki bir uyanışı simgeliyor. Bilinçaltın sana değişime hazır olman gerektiğini fısıldıyor.";

    if (mounted) {
      setState(() {
        isAnalyzing = false;
        resultText = analysis;
      });
      _speak(analysis);
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop();
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("BİLİNÇALTI TARAYICI", style: AppTextStyles.orbitronStyle),
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
              "Rüyalar, ruhun fısıltılarıdır.\nGördüklerini anlat, sembolleri çözelim.",
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
                decoration: const InputDecoration(
                  hintText: "Örn: Bir ormanda kayboldum...",
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
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
                child: Text("SİMGELERİ ÇÖZ", style: AppTextStyles.orbitronStyle),
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
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.white54),
                      onPressed: () => _speak(resultText!),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
