import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color deepSpace = Color(0xFF050510); // Darker than black, slight blue tint
  static const Color deepBlack = deepSpace; // Alias for backward compatibility
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonPurple = Color(0xFFBC13FE);
  static const Color hologramBlue = Color(0x8800C2FF);
  static const Color errorRed = Color(0xFFFF2A6D);
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color surfaceDark = Color(0xFF121212); // Added missing color
  
  // Gradients
  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F0C29),
      Color(0xFF302B63),
      Color(0xFF24243E),
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepSpace,
      primaryColor: neonCyan,
      
      textTheme: TextTheme(
        // Headers: Sci-Fi / Wide
        displayLarge: GoogleFonts.orbitron(
           fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: 2
        ),
        displayMedium: GoogleFonts.orbitron(
           fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 1.5
        ),
        
        // Body: Clean Sans-Serif
        bodyLarge: GoogleFonts.inter(
           fontSize: 16, color: textPrimary.withValues(alpha: 0.9), height: 1.5
        ),
        bodyMedium: GoogleFonts.inter(
           fontSize: 14, color: textPrimary.withValues(alpha: 0.8), height: 1.4
        ),
        
        // Data/Technical: Monospace
        labelLarge: GoogleFonts.jetBrainsMono(
           fontSize: 12, color: neonCyan.withValues(alpha: 0.8), letterSpacing: 1
        ),
      ),
      
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPurple,
        surface: Color(0xFF121212),
        error: errorRed,
        onPrimary: Colors.black,
      ),
      iconTheme: const IconThemeData(color: neonCyan),
    );
  }
}
