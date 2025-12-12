import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/data_stream/presentation/data_stream_screen.dart';
import 'package:tekno_mistik/features/oracle/presentation/oracle_screen.dart';
import 'package:tekno_mistik/features/settings/presentation/settings_screen.dart';
import 'package:tekno_mistik/features/tarot/presentation/prophecy_screen.dart';
import 'package:tekno_mistik/features/store/presentation/store_screen.dart'; // NEW IMPORT
import 'package:tekno_mistik/features/profile/presentation/providers/user_settings_provider.dart';

class MainWrapper extends ConsumerStatefulWidget {
  const MainWrapper({super.key});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const DataStreamScreen(),
    const OracleScreen(),
    const StoreScreen(), // NEW CENTER TAB
    const ProphecyScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Check if user is known, if not hint at settings (can be refined with a dialog, but logic here directs awareness)
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final settings = ref.read(userSettingsProvider);
       if (settings.name.isEmpty) {
         // Optionally navigate to Settings index if needed, but for now we start at DataStream as "Anonymous Traveler"
         // or we could force it:
         // _onItemTapped(3);
       }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false, // Critical for avoiding keyboard push-up issues on gradient
      body: Stack(
        children: [
          // GLOBAL DEEP MYSTIC GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F0C29), // Deepest Dark
                  Color(0xFF302B63), // Purple Mystery
                  Color(0xFF24243E), // Cosmic Night
                ],
              ),
            ),
          ),
          
          // Content
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0F0C29).withOpacity(0.2), 
                const Color(0xFF0F0C29).withOpacity(0.95),
              ]
            ),
            border: Border(top: BorderSide(color: AppTheme.neonPurple.withOpacity(0.3), width: 0.5)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.neonCyan,
            unselectedItemColor: AppTheme.neonPurple.withOpacity(0.4),
            selectedLabelStyle: AppTheme.orbitronStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTheme.orbitronStyle.copyWith(fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.waves),
                label: 'VERİ AKIŞI',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.remove_red_eye),
                label: 'ORACLE',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star), // NEW CENTER ICON
                label: 'MAĞAZA',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome),
                label: 'KEHANET',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_suggest),
                label: 'AYARLAR',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
