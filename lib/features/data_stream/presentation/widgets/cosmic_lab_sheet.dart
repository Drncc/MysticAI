import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/i18n/app_localizations.dart';
// import '../../../../core/theme/app_colors.dart'; // Renk hatasını önlemek için kapattık
import '../../../../core/services/share_service.dart';
import '../../../love/presentation/love_screen.dart';
import '../../../dream/presentation/dream_screen.dart';
import '../../../ritual/presentation/ritual_screen.dart';

class CosmicLabSheet extends StatelessWidget {
  const CosmicLabSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1E).withOpacity(0.9), 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: Colors.purpleAccent.withOpacity(0.3))),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kulp (Handle)
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(tr.translate('lab_title'), style: AppTextStyles.h2.copyWith(fontSize: 18, color: Colors.cyanAccent)), 
              const SizedBox(height: 5),
              Text(tr.translate('lab_subtitle'), style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: Colors.white54)), 
              
              const SizedBox(height: 30),

              // GRID MENU
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.3,
                  children: [
                    _buildLabCard(
                      context, 
                      tr.translate('lab_love'), 
                      Icons.favorite, 
                      Colors.pinkAccent, 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoveScreen())),
                      isLocked: true
                    ),
                    _buildLabCard(
                      context, 
                      tr.translate('lab_dream'), 
                      Icons.psychology, 
                      Colors.purpleAccent, 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DreamScreen())),
                    ),
                    _buildLabCard(
                      context, 
                      tr.translate('lab_ritual'), 
                      Icons.self_improvement, 
                      Colors.amberAccent, 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RitualScreen())),
                    ),
                    _buildLabCard(
                      context, 
                      tr.translate('lab_share'), 
                      Icons.share, 
                      Colors.cyanAccent, 
                      () => ShareService.captureAndShare(context), 
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, {bool isLocked = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(height: 10),
                  Text(title, style: AppTextStyles.button.copyWith(fontSize: 12, color: Colors.white)), // orbitronStyle to button
                ],
              ),
            ),
            if (isLocked)
              Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.lock, color: Colors.white38, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
