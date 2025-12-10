import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/onboarding/presentation/onboarding_screen.dart';
import 'package:tekno_mistik/features/dashboard/presentation/dashboard_screen.dart';
import 'package:tekno_mistik/core/config/env_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load from Config Class
  const supabaseUrl = EnvConfig.supabaseUrl;
  const supabaseAnonKey = EnvConfig.supabaseAnonKey;

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      debugPrint("SUPABASE INITIALIZED: $supabaseUrl");
  } else {
      debugPrint("CRITICAL ERROR: Supabase keys are missing in config!");
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tekno-Mistik',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    final session = Supabase.instance.client.auth.currentSession;
    // Check if user has a profile (conceptually). For now just session check.
    // In a real app we might fetch profile to confirm onboarding is done.
    if (session != null) {
      return const DashboardScreen();
    }
    return const OnboardingScreen();
  }
}
