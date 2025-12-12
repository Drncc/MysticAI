import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/main_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAgreed = false;

  void _handleLogin() {
    if (!_isAgreed) return;
    
    // Navigate to Main App
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND (The Fool Card)
          Positioned.fill(
            child: Image.asset(
              'assets/tarot/0_fool_1.jpg', // Using Fool card as requested
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback gradient if asset missing
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 2. DARK OVERLAY & BLUR
          Positioned.fill(
              child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          )),
          
          // 3. CONTENT
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // LOGO / TITLE
                Column(
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.neonCyan, size: 60)
                         .animate(onPlay: (c)=>c.repeat(reverse: true))
                         .scaleXY(end: 1.2, duration: 2.seconds)
                         .then().shimmer(duration: 2.seconds, color: AppTheme.neonPurple),
                    const SizedBox(height: 20),
                    Text(
                      "MYSTIC AI",
                      style: AppTheme.orbitronStyle.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: AppTheme.neonPurple, blurRadius: 30),
                          Shadow(color: AppTheme.neonCyan, blurRadius: 10),
                        ]
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Kaderin Dijital Yansıması",
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 16,
                        letterSpacing: 2
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 1.seconds).slideY(begin: -0.2),

                const Spacer(flex: 3),

                // BOTTOM PANEL
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GlassCard(
                    color: Colors.black.withOpacity(0.4),
                    borderColor: AppTheme.neonPurple.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                          // CHECKBOX (Legal)
                          Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.white54),
                            child: CheckboxListTile(
                              value: _isAgreed,
                              activeColor: AppTheme.neonPurple,
                              checkColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (val) => setState(() => _isAgreed = val ?? false),
                              title: Text(
                                "Hizmet şartlarını, gizlilik politikasını ve bu uygulamanın sadece eğlence amaçlı olduğunu kabul ediyorum.",
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // LOGIN BUTTON (Google)
                          AnimatedOpacity(
                            duration: 300.ms,
                            opacity: _isAgreed ? 1.0 : 0.5,
                            child: ElevatedButton(
                              onPressed: _isAgreed ? _handleLogin : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: _isAgreed ? 10 : 0,
                                shadowColor: AppTheme.neonCyan.withOpacity(0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.login, color: Colors.black), // Placeholder for Google Icon
                                  const SizedBox(width: 10),
                                  Text(
                                    "GOOGLE İLE KOZMİK BAĞ KUR",
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // GUEST LOGIN
                          TextButton(
                            onPressed: _handleLogin,
                            child: Text(
                              "Şimdilik Anonim Gezgin Olarak Gir",
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                decoration: TextDecoration.underline,
                                fontSize: 12
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
