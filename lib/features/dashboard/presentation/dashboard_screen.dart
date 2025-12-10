import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tekno_mistik/core/services/share_service.dart';
import 'package:tekno_mistik/core/services/oracle_service.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/dashboard/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/features/oracle/presentation/oracle_screen.dart';
import 'package:tekno_mistik/features/profile/presentation/profile_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final _pages = const [
    DashboardView(),
    OracleScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBlack,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.surfaceDark,
        indicatorColor: AppTheme.neonCyan.withValues(alpha: 0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.neonCyan),
            label: 'Veri Akışı',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
             selectedIcon: Icon(Icons.psychology, color: AppTheme.neonCyan),
            label: 'Oracle',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
             selectedIcon: Icon(Icons.settings, color: AppTheme.neonCyan),
            label: 'Protokol',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const SizedBox(height: 20),
              Text(
                "HOŞ GELDİN,\nGEZGİN.",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: AppTheme.neonCyan.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ).animate()
               .fadeIn(duration: 800.ms)
               .slideX(begin: -0.1, curve: Curves.easeOutExpo)
               .shimmer(duration: 2.seconds, delay: 1.seconds),
              
              const SizedBox(height: 20),

              // Daily Insight Card
              FutureBuilder<String>(
                future: OracleService().checkAndGenerateDailyInsight(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                     return const GlassCard(
                       child: Center(child: LinearProgressIndicator(color: AppTheme.neonPurple)),
                     ).animate().fadeIn();
                  }
                  return Column(
                    children: [
                      Screenshot(
                        controller: _screenshotController,
                        child: GlassCard(
                          borderColor: AppTheme.neonPurple,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: AppTheme.neonPurple, size: 16),
                                  const SizedBox(width: 8),
                                  Text("GÜNÜN KEHANETİ", style: GoogleFonts.orbitron(fontSize: 12, color: AppTheme.neonPurple)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.data ?? "Veri akışı bekleniyor...",
                                style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              Text("Generated by MysticAI", style: GoogleFonts.orbitron(fontSize: 8, color: Colors.white24)),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                           icon: const Icon(Icons.share, size: 16, color: Colors.white30),
                           onPressed: () => ShareService.shareWidget(_screenshotController),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 1.seconds).slideY();
                },
              ),

              const SizedBox(height: 30),

              // Data Cards Section
              Text(
                "ANLIK VERİ AKIŞI",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.neonCyan.withValues(alpha: 0.6),
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 10),

              // Cards
              const GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("BİYO-RİTİM", style: TextStyle(color: Colors.white70)),
                        Icon(Icons.monitor_heart_outlined, color: AppTheme.neonPurple),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "%87", 
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Senkronizasyon ideal seviyede.",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

              const GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text("RUHSAL REZONANS", style: TextStyle(color: Colors.white70)),
                         Icon(Icons.waves, color: AppTheme.neonCyan),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "DURGUN", 
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                     Text(
                      "Dış etkenler minimum düzeyde.",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),

              const GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text("DİJİTAL ENTROPİ", style: TextStyle(color: Colors.white70)),
                         Icon(Icons.data_usage, color: AppTheme.errorRed),
                      ],
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: 0.3,
                      backgroundColor: Colors.white10,
                      color: AppTheme.errorRed,
                    ),
                    SizedBox(height: 10),
                     Text(
                      "Veri gürültüsü analiz ediliyor...",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
            ],
          ),
        ),
    );
  }
}
