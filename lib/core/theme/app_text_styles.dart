import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // --- TEMEL STİLLER ---
  
  // Orbitron (Başlıklar ve Neon Efektler için)
  static TextStyle get orbitronStyle => GoogleFonts.orbitron(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    shadows: [
      const Shadow(
        blurRadius: 10.0,
        color: Colors.purpleAccent,
        offset: Offset(0, 0),
      ),
    ],
  );

  // Inter (Okunabilir Gövde Metinleri için)
  static TextStyle get interStyle => GoogleFonts.inter(
    color: Colors.white70,
    fontSize: 14,
  );

  // --- BAŞLIKLAR ---
  static TextStyle get h1 => orbitronStyle.copyWith(fontSize: 24);
  static TextStyle get h2 => orbitronStyle.copyWith(fontSize: 20);
  static TextStyle get h3 => orbitronStyle.copyWith(fontSize: 18);

  // --- GÖVDE METİNLERİ (HATA ÇÖZÜMÜ BURADA) ---
  
  // Büyük Metin
  static TextStyle get bodyLarge => interStyle.copyWith(fontSize: 16, color: Colors.white);
  
  // ORTA METİN (EKSİK OLAN BUYDU)
  static TextStyle get bodyMedium => interStyle.copyWith(fontSize: 14, color: Colors.white70);
  
  // Varsayılan Body (Yedek)
  static TextStyle get body => bodyMedium; 

  // Küçük Metin
  static TextStyle get bodySmall => interStyle.copyWith(fontSize: 12, color: Colors.white54);

  // --- UI ELEMENTLERİ ---
  static TextStyle get button => orbitronStyle.copyWith(fontSize: 16);
  static TextStyle get label => interStyle.copyWith(fontWeight: FontWeight.bold);
}
