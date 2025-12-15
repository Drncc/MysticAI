import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import '../../../../core/theme/app_text_styles.dart';

class RitualScreen extends StatefulWidget {
  const RitualScreen({super.key});

  @override
  State<RitualScreen> createState() => _RitualScreenState();
}

class _RitualScreenState extends State<RitualScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isPressing = false;
  double progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Nefes alma efekti
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startRitual() {
    setState(() => isPressing = true);
    
    // Titreşim başlat (Destekliyorsa)
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(duration: 3000);
    });

    // İlerleme Sayacı (3 Saniye sürecek)
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        progress += 0.02; // Her 50ms'de %2 artır
        if (progress >= 1.0) {
          _completeRitual();
        }
      });
    });
  }

  void _stopRitual() {
    if (progress < 1.0) {
      _timer?.cancel();
      Vibration.cancel();
      setState(() {
        isPressing = false;
        progress = 0.0;
      });
    }
  }

  void _completeRitual() {
    _timer?.cancel();
    Vibration.vibrate(duration: 500); // Bitiş titreşimi
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text("NİYET KODLANDI", style: AppTextStyles.orbitronStyle.copyWith(color: Colors.cyanAccent)),
        content: Text(
          "Enerjin evrensel veritabanına işlendi. Şimdi akışa güven.",
          style: AppTextStyles.interStyle,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                isPressing = false;
                progress = 0.0;
              });
            },
            child: const Text("TAMAM", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("RİTÜEL ODASI", style: AppTextStyles.orbitronStyle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isPressing ? "ENERJİ YÜKLENİYOR... %${(progress * 100).toInt()}" : "DAİREYE BASILI TUT",
              style: AppTextStyles.orbitronStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 50),
            
            // ETKİLEŞİMLİ DAİRE
            GestureDetector(
              onLongPressStart: (_) => _startRitual(),
              onLongPressEnd: (_) => _stopRitual(),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // HATA ÇÖZÜMÜ: Değerleri güvenli aralıkta tutuyoruz (Clamp)
                  double pulse = _controller.value * 10; 
                  double size = 150 + (progress * 100); // Büyüme efekti
                  
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: isPressing ? Colors.purpleAccent : Colors.cyanAccent,
                        width: 2 + (progress * 5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isPressing ? Colors.purpleAccent : Colors.cyanAccent).withOpacity(0.5),
                          blurRadius: 20 + pulse + (progress * 50), // Güvenli artış
                          spreadRadius: 2 + (progress * 10),
                        )
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.fingerprint, 
                        size: 60 + (progress * 20),
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
