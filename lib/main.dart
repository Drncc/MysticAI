import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekno_mistik/core/config/env_config.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/auth/presentation/login_screen.dart'; // UPDATED Import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load Env
  // await dotenv.load(fileName: ".env"); // Using EnvConfig consts instead for safety
  
  // Init Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MysticAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(), // UPDATED: Starts with Login Screen
    );
  }
}
