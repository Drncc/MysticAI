import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cyberpunk Palette
  static const Color deepBlack = Color(0xFF000000);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonPurple = Color(0xFFBC13FE);
  static const Color neonPurpleLight = Color(0xFFD67EFF);
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color errorRed = Color(0xFFFF0033);
  static const Color textSecondary = Color(0xB3FFFFFF); // White with ~70% opacity
  static const Color textPrimary = Color(0xFFFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepBlack,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPurple,
        surface: surfaceDark,
        error: errorRed,
        onPrimary: deepBlack,
        onSecondary: Colors.white,
        onSurface: neonCyan,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: neonCyan,
          letterSpacing: 2.0,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: neonCyan,
          letterSpacing: 1.5,
        ),
        bodyLarge: GoogleFonts.jetBrainsMono(
          fontSize: 16,
          color: Colors.white.withValues(alpha: 0.9),
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.8),
        ),
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: deepBlack,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: neonCyan.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: neonCyan.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: neonCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: GoogleFonts.jetBrainsMono(color: neonCyan.withValues(alpha: 0.7)),
        hintStyle: GoogleFonts.jetBrainsMono(color: Colors.white.withValues(alpha: 0.3)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonCyan,
          foregroundColor: deepBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2), // Cyberpunk sharp edges
          ),
          textStyle: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}
