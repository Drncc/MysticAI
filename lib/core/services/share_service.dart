import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  // 1. ScreenshotController ile Yakala
  static Future<void> shareWidget(ScreenshotController controller) async {
    try {
      final Uint8List? image = await controller.capture();
      if (image != null) {
        await _shareImage(image);
      }
    } catch (e) {
      debugPrint("Hata oluştu: $e");
    }
  }

  // 2. Context ile Sanal Widget Yakala (LoveScreen İçin KRİTİK METOT)
  static Future<void> captureAndShare(BuildContext context) async {
    try {
      ScreenshotController tempController = ScreenshotController();
      
      // Ekrana basılmayan sanal bir widget oluşturup fotosunu çekiyoruz
      final Uint8List? image = await tempController.captureFromWidget(
        Container(
           padding: const EdgeInsets.all(20),
           color: const Color(0xFF0F0F1E),
           child: Center(
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 const Icon(Icons.favorite, size: 50, color: Colors.pinkAccent),
                 const SizedBox(height: 20),
                 const Text(
                   "Mystic AI", 
                   style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                   textDirection: TextDirection.ltr,
                 ),
                 const SizedBox(height: 10),
                 const Text(
                   "Kozmik Uyum Analizi",
                   style: TextStyle(color: Colors.white70, fontSize: 16),
                   textDirection: TextDirection.ltr,
                 ),
               ],
             ),
           ),
        ),
        delay: const Duration(milliseconds: 100)
      );

      if (image != null) {
        await _shareImage(image);
      }
      
    } catch (e) {
      debugPrint("Capture Error: $e");
    }
  }

  static Future<void> _shareImage(Uint8List imageBytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/mystic_share.png').create();
      await imagePath.writeAsBytes(imageBytes);

      // XFile kullanımı (Share Plus v9.0 uyumlu)
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Mystic AI Kozmik Analizim! 🌌',
      );
    } catch (e) {
       debugPrint("Dosya yazma hatası: $e");
    }
  }
}