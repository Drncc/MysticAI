import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareWidget(ScreenshotController controller) async {
    try {
      await HapticFeedback.mediumImpact();
      
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await controller.captureAndSave(directory.path, fileName: "mystic_echo.png");
      
      if (imagePath != null) {
        await Share.shareXFiles([XFile(imagePath)], text: 'MysticAI: Dijital Yansıma');
      }
    } catch (e) {
      // Handle error
    }
  }
}
