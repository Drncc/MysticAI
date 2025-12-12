import 'package:flutter/material.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';

class ProtocolScreen extends StatelessWidget {
  const ProtocolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("PROTOKOL AYARLARI", style: AppTheme.orbitronStyle),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_suggest, size: 64, color: AppTheme.neonCyan.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              "SİSTEM v1.0 ONLINE",
              style: AppTheme.orbitronStyle.copyWith(color: Colors.white38, letterSpacing: 2),
            ),
            const SizedBox(height: 40),
            // Mock Settings
            _buildSwitch("Haptik Geri Bildirim", true),
            _buildSwitch("Ses Efektleri", true),
            _buildSwitch("Yüksek Kontrast", false),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(String title, bool val) {
    return SizedBox(
      width: 300,
      child: SwitchListTile(
        title: Text(title, style: AppTheme.interStyle.copyWith(color: Colors.white70)),
        value: val, 
        onChanged: (v){},
        activeColor: AppTheme.neonCyan,
        activeTrackColor: AppTheme.neonCyan.withOpacity(0.3),
      ),
    );
  }
}
