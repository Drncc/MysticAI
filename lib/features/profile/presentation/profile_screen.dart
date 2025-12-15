import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/user_settings_provider.dart';
import 'package:tekno_mistik/core/i18n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Simulating sensors
  double _magneticField = 45.0;
  double _chaosLevel = 12.0;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _startSensorSimulation();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _startSensorSimulation() {
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return;
      setState(() {
        final random = Random();
        _magneticField = 40.0 + random.nextDouble() * 10.0 - 5.0; 
        _chaosLevel = (_chaosLevel + (random.nextDouble() * 4 - 2)).clamp(0.0, 100.0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);
    final notifier = ref.read(userSettingsProvider.notifier);
    final tr = AppLocalizations.of(context); // Localization helper

    const cardColor = Color(0xFF1E1E1E);
    const accentColor = Color(0xFFBB86FC);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text("PROFİL", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        actions: [
          // LANGUAGE SELECTOR
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<Locale>(
              value: ref.watch(localeProvider),
              dropdownColor: const Color(0xFF1E1E1E),
              icon: const Icon(Icons.language, color: accentColor),
              underline: Container(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  ref.read(localeProvider.notifier).switchLanguage(newLocale);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('tr', 'TR'),
                  child: Text('TR', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                DropdownMenuItem(
                  value: Locale('en', 'US'),
                  child: Text('EN', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BÖLÜM 1: KİŞİSEL BİLGİLER
            Text("KİMLİK", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                   // ... (Inputs kept hardcoded as requested)
                  _buildModernTextField(
                    label: "Ad Soyad",
                    initialValue: settings.name,
                    onChanged: notifier.updateName,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernTextField(
                          label: "Boy (cm)",
                          initialValue: settings.height,
                          onChanged: notifier.updateHeight,
                          icon: Icons.height,
                          numeric: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModernTextField(
                          label: "Kilo (kg)",
                          initialValue: settings.weight,
                          onChanged: notifier.updateWeight,
                          icon: Icons.monitor_weight_outlined,
                          numeric: true,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // BÖLÜM 2: KOZMİK KİMLİK
            Text("KOZMİK KİMLİK", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                       final date = await showDatePicker(
                          context: context,
                          initialDate: settings.birthDate ?? DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: accentColor,
                                  onPrimary: Colors.black,
                                  surface: cardColor,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          }
                       );
                       if (date != null) notifier.updateBirthDate(date);
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.calendar_today, color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Doğum Tarihi", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                            Text(
                              settings.birthDate != null 
                                ? "${settings.birthDate!.day}.${settings.birthDate!.month}.${settings.birthDate!.year}"
                                : "Seçiniz", 
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 16)
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (settings.zodiacSign != 'BİLİNMİYOR')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(settings.zodiacSign, style: GoogleFonts.inter(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10)),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Burç Oracle'a Dahil Edilsin", style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                    subtitle: Text("Yapay zeka cevaplarında burç etkiniz hesaplanır.", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                    value: settings.includeZodiacInOracle,
                    activeColor: accentColor,
                    onChanged: notifier.toggleZodiacInOracle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // BÖLÜM 3: BİYOMETRİK ÖZET
            Text("ANLIK BİYOMETRİ (SİMÜLASYON)", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildBiometricRow(tr.translate('magnetic_flux_label'), "${_magneticField.toStringAsFixed(1)} µT", _magneticField / 60, Colors.cyanAccent),
                  const SizedBox(height: 16),
                  _buildBiometricRow(tr.translate('entropy_label'), "${_chaosLevel.toInt()}%", _chaosLevel / 100, Colors.redAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required String label, 
    required String initialValue, 
    required Function(String) onChanged, 
    required IconData icon,
    bool numeric = false,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.black12,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      ),
    );
  }

  Widget _buildBiometricRow(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(color: Colors.white70)),
            Text(value, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.black26,
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
