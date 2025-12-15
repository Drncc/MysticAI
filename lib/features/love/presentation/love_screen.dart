import 'package:flutter/material.dart';
import 'dart:ui';
// IMPORTLAR
import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_text_styles.dart';

class LoveScreen extends StatefulWidget {
  const LoveScreen({super.key});

  @override
  State<LoveScreen> createState() => _LoveScreenState();
}

class _LoveScreenState extends State<LoveScreen> {
  String? mySign;
  String? partnerSign;
  bool isAnalyzing = false;
  String? resultText;
  int? matchPercentage;

  final List<String> signs = [
    "Koç", "Boğa", "İkizler", "Yengeç", "Aslan", "Başak",
    "Terazi", "Akrep", "Yay", "Oğlak", "Kova", "Balık"
  ];

  void _analyzeLove() async {
    if (mySign == null || partnerSign == null) return;

    setState(() {
      isAnalyzing = true;
      resultText = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isAnalyzing = false;
      matchPercentage = (mySign!.length + partnerSign!.length) * 7 % 100; 
      if (matchPercentage! < 20) matchPercentage = 40 + matchPercentage!;
      
      resultText = "Elementleriniz arasında güçlü bir manyetik çekim var. Ancak Merkür retrosunda iletişim kazalarına dikkat etmelisiniz.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // HATA BURADAYDI: Artık AppTextStyles.orbitronStyle tanımlı!
        title: Text("KOZMİK UYUM", style: AppTextStyles.orbitronStyle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F1E), Color(0xFF1E1E2C)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.favorite, size: 80, color: Colors.pinkAccent),
                const SizedBox(height: 30),

                _buildDropdown("Senin Burcun", mySign, (val) => setState(() => mySign = val)),
                const SizedBox(height: 15),
                _buildDropdown("Partnerin Burcu", partnerSign, (val) => setState(() => partnerSign = val)),
                
                const SizedBox(height: 40),

                if (!isAnalyzing && resultText == null)
                  ElevatedButton(
                    onPressed: (mySign != null && partnerSign != null) ? _analyzeLove : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text("ANALİZ ET", style: AppTextStyles.orbitronStyle.copyWith(fontSize: 16)),
                  ),

                if (isAnalyzing)
                  const CircularProgressIndicator(color: Colors.pinkAccent),

                if (resultText != null)
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text("%$matchPercentage UYUM", style: AppTextStyles.orbitronStyle.copyWith(fontSize: 32, color: Colors.pinkAccent)),
                        const SizedBox(height: 15),
                        Text(
                          resultText!,
                          textAlign: TextAlign.center,
                          // HATA BURADAYDI: Artık AppTextStyles.interStyle tanımlı!
                          style: AppTextStyles.interStyle.copyWith(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        
                        TextButton.icon(
                          onPressed: () {
                            ShareService.captureAndShare(context);
                          },
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text("SONUCU PAYLAŞ", style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white54)),
          dropdownColor: const Color(0xFF1E1E2C),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.pinkAccent),
          isExpanded: true,
          items: signs.map((String sign) {
            return DropdownMenuItem<String>(
              value: sign,
              child: Text(sign, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
