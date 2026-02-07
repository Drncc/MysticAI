import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/data_stream/presentation/data_stream_screen.dart';
import 'package:tekno_mistik/features/oracle/presentation/oracle_screen.dart';
import 'package:tekno_mistik/features/settings/presentation/settings_screen.dart';
import 'package:tekno_mistik/features/tarot/presentation/prophecy_screen.dart';
import 'package:tekno_mistik/features/store/presentation/store_screen.dart'; 

import 'package:tekno_mistik/features/profile/presentation/providers/user_settings_provider.dart';
import 'package:tekno_mistik/core/i18n/app_localizations.dart';

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
    const StoreScreen(),
    const ProphecyScreen(),

  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final settings = ref.read(userSettingsProvider);
       // Initial check logic if needed
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
    final tr = AppLocalizations.of(context);
    final titles = [
      tr.translate('nav_data'),
      tr.translate('nav_oracle'),
      tr.translate('nav_store'),
      tr.translate('nav_prophecy'),

    ];

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false, 
      appBar: AppBar(
        title: Text(titles[_currentIndex], style: AppTheme.orbitronStyle.copyWith(fontSize: 16, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent for gradient
        elevation: 0,
        leading: Icon(Icons.auto_awesome, color: AppTheme.neonCyan.withOpacity(0.5)), // Small Logo
        actions: [
          // LANGUAGE SELECTOR ICON
          IconButton(
            icon: const Icon(Icons.language, color: AppTheme.neonCyan),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: Text('Dil Seçimi / Language', style: AppTheme.orbitronStyle.copyWith(color: AppTheme.neonCyan)),
                  children: [
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(localeProvider.notifier).switchLanguage(const Locale('tr', 'TR'));
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('Türkçe (TR)', style: AppTheme.interStyle.copyWith(color: Colors.white)),
                      ),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(localeProvider.notifier).switchLanguage(const Locale('en', 'US'));
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('English (EN)', style: AppTheme.interStyle.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: AppTheme.neonPurple), 
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // GLOBAL DEEP MYSTIC GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F0C29), 
                  Color(0xFF302B63), 
                  Color(0xFF24243E), 
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
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.waves),
                label: tr.translate('nav_data'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.remove_red_eye),
                label: tr.translate('nav_oracle'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.star), 
                label: tr.translate('nav_store'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.auto_awesome),
                label: tr.translate('nav_prophecy'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
