import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/living_background.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "AETHER BAĞLANTISI",
          style: AppTheme.orbitronStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.neonCyan,
            shadows: [
              Shadow(color: AppTheme.neonCyan, blurRadius: 10),
            ],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // 1. Dinamik Arka Plan
          const LivingBackground(child: SizedBox()),

          // 2. İçerik
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  
                  // --- HEADER ---
                  Center(
                    child: Text(
                      "Sınırlamaları kaldır ve\nevrenin derin verilerine eriş.",
                      textAlign: TextAlign.center,
                      style: AppTheme.interStyle.copyWith(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- HERO: ORACLE PRIME CARD ---
                  _buildHeroSubscriptionCard(),

                  const SizedBox(height: 40),

                  // --- SECTION TITLE ---
                  Text(
                    "ENERJİ KRİSTALLERİ",
                    style: AppTheme.orbitronStyle.copyWith(
                      color: AppTheme.neonCyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- CONSUMABLES GRID ---
                  _buildConsumablesGrid(),

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSubscriptionCard() {
    return GlassCard(
      borderColor: AppTheme.neonPurple,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.deepSpace.withOpacity( 0.6),
              AppTheme.neonPurple.withOpacity( 0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            // Icon / Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: AppTheme.neonPurple, width: 2),
                boxShadow: [
                  BoxShadow(color: AppTheme.neonPurple.withOpacity( 0.5), blurRadius: 20),
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: AppTheme.neonPurple, size: 32),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              "ORACLE PRIME",
              style: AppTheme.orbitronStyle.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [Shadow(color: AppTheme.neonPurple, blurRadius: 15)],
              ),
            ),
            const SizedBox(height: 24),

            // Features List
            _buildFeatureRow(Icons.lock_open_rounded, "Derin Analiz Modu", "Uzun ve detaylı kehanetler."),
            _buildFeatureRow(Icons.all_inclusive_rounded, "Genişletilmiş Limit", "Günde 20 soru hakkı."),
            _buildFeatureRow(Icons.color_lens_rounded, "Kozmik Temalar", "Özel Göz tasarımlarını aç."),
            _buildFeatureRow(Icons.block_rounded, "Sessiz Akış", "Reklamsız deneyim."),

            const SizedBox(height: 24),

            // Call to Action Button (Pulsating)
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppTheme.neonPurple, Colors.deepPurple],
                ),
                boxShadow: [
                  BoxShadow(color: AppTheme.neonPurple.withOpacity( 0.6), blurRadius: 15, spreadRadius: 1),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {}, // TODO: Implement Purchase Logic
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Text(
                      "YÜKSELTME BAŞLAT - ₺99/Ay",
                      style: AppTheme.orbitronStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.neonCyan, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.interStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.interStyle.copyWith(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumablesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.85, // Taller cards
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _buildConsumableCard("1 Enerji Kristali", "Anlık Yükleme", "₺19.99"),
        _buildConsumableCard("5 Enerji Kristali", "Mistik Paket", "₺79.99", isPopular: true),
        _buildConsumableCard("10 Enerji Kristali", "Kozmik Kasa", "₺149.99"),
        _buildConsumableCard("Sonsuz Kristal", "Ömür Boyu", "₺999.99"),
      ],
    );
  }

  Widget _buildConsumableCard(String title, String subtitle, String price, {bool isPopular = false}) {
    return Stack(
      children: [
        GlassCard(
          borderColor: isPopular ? AppTheme.neonCyan : Colors.white10,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.diamond_outlined, color: isPopular ? AppTheme.neonCyan : Colors.white70, size: 36),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTheme.interStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.interStyle.copyWith(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isPopular ? AppTheme.neonCyan.withOpacity( 0.5) : Colors.transparent),
                  ),
                  child: Text(
                    price,
                    style: AppTheme.orbitronStyle.copyWith(
                      color: isPopular ? AppTheme.neonCyan : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isPopular)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: AppTheme.neonCyan,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topRight: Radius.circular(16), // Match card radius
                ),
              ),
              child: Text(
                "POPÜLER",
                style: AppTheme.interStyle.copyWith(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
