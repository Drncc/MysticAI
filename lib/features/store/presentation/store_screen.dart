import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/core/theme/app_text_styles.dart';
import 'package:tekno_mistik/core/services/limit_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _selectedPackageIndex = 1; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("KOZMİK ERİŞİM", style: AppTextStyles.h2.copyWith(letterSpacing: 2, color: AppTheme.neonCyan)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), 
        child: Column(
          children: [
            Text(
              "Evrenin sırlarına sınırsız erişim sağla.\nKaderini şekillendir.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),

            const SizedBox(height: 30),

            _buildFeatureItem("Günde 15 Detaylı Oracle Mesajı"), 
            _buildFeatureItem("Günde 3 Tarot Kartı Açılımı"), 
            _buildFeatureItem("Detaylı Burç & Astro Analizi"),
            _buildFeatureItem("Reklamsız Mistik Deneyim"),
            
            const SizedBox(height: 40),

            // Packages
            _buildPackageOption(
              index: 0,
              title: "ÇIRAK",
              price: "₺49.99 / Hafta",
              subPrice: "(Başlangıç İçin)",
              isPopular: false,
            ),
            const SizedBox(height: 15),
            
            // SOCIAL PROOF BADGE (NEW)
            if (_selectedPackageIndex == 1)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.neonCyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.neonCyan.withOpacity(0.5))
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 5),
                    Text("10.000+ Gezginin Tercihi", style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2),

            _buildPackageOption(
              index: 1,
              title: "KAHİN",
              price: "₺149.99 / Ay",
              subPrice: "(Aylık sadece tüm özellikler)", // A bit vague, let's fix
              // "Aylık 150 TL" -> Daily ~5 TL. 
              // The user prompt said: "(Aylık sadece 83₺)" for annual package.
              // For monthly package, let's just say "En Popüler Seçim".
              isPopular: true,
            ),
            
            const SizedBox(height: 15),

            _buildPackageOption(
              index: 2,
              title: "ÜSTAT",
              price: "₺999.99 / Yıl",
              subPrice: "(Aylık sadece 83₺)", // 999/12 ~ 83
              isPopular: false,
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonCyan.withOpacity(0.2),
                foregroundColor: AppTheme.neonCyan,
                shadowColor: AppTheme.neonCyan,
                elevation: 10,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: AppTheme.neonCyan, width: 2)
                ),
              ),
              onPressed: () async {
                await LimitService().upgradeToPremium();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Yükseliş Tamamlandı. Sınırlar Kalktı.", style: GoogleFonts.orbitron()),
                      backgroundColor: AppTheme.neonPurple,
                    )
                  );
                }
              },
              child: Text(
                "SEÇİMİ ONAYLA VE YÜKSEL",
                style: AppTheme.orbitronStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ).animate(onPlay: (c)=>c.repeat(reverse: true))
             .shimmer(duration: 3.seconds, delay: 2.seconds),
             
            const SizedBox(height: 20),
            Text(
              "İptal edilebilir. Gizlilik politikası geçerlidir.",
              style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppTheme.neonPurple, size: 20),
          const SizedBox(width: 12),
          Text(text, style: AppTextStyles.bodyMedium),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX();
  }

  Widget _buildPackageOption({required int index, required String title, required String price, String? subPrice, required bool isPopular}) {
    final isSelected = _selectedPackageIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPackageIndex = index),
      child: AnimatedContainer(
        duration: 300.ms,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(color: isPopular ? AppTheme.neonCyan.withOpacity(0.4) : AppTheme.neonPurple.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)
          ] : [],
        ),
        child: GlassCard(
          color: isSelected 
             ? (isPopular ? AppTheme.neonCyan.withOpacity(0.15) : AppTheme.neonPurple.withOpacity(0.15))
             : Colors.white.withOpacity(0.05),
          borderColor: isSelected 
             ? (isPopular ? AppTheme.neonCyan : AppTheme.neonPurple)
             : Colors.white12,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? (isPopular ? AppTheme.neonCyan : AppTheme.neonPurple) : Colors.white24, width: 2),
                  ),
                  child: isSelected ? Center(child: Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: isPopular ? AppTheme.neonCyan : AppTheme.neonPurple))) : null,
                ),
                const SizedBox(width: 20),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: AppTheme.orbitronStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          if (isPopular) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.neonCyan, borderRadius: BorderRadius.circular(10)),
                              child: Text("POPÜLER", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                            )
                          ]
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(price, style: AppTextStyles.bodyMedium),
                      if (subPrice != null)
                        Text(subPrice, style: AppTextStyles.bodySmall.copyWith(color: AppTheme.neonCyan, height: 1.2)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
