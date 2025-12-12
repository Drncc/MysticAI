import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final history = [
      {"q": "Aşk hayatım ne olacak?", "date": "Bugün 14:30"},
      {"q": "Yazılım kariyerim...", "date": "Dün 22:15"},
      {"q": "İstanbul'da hava durumu", "date": "10 Aralık"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text("GEÇMİŞ", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 20),
              ),
              title: Text(item['q']!, style: GoogleFonts.inter(color: Colors.white)),
              subtitle: Text(item['date']!, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
