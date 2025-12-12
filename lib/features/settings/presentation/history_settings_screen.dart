import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/user_settings_provider.dart';

class HistorySettingsScreen extends ConsumerStatefulWidget {
  const HistorySettingsScreen({super.key});

  @override
  ConsumerState<HistorySettingsScreen> createState() => _HistorySettingsScreenState();
}

class _HistorySettingsScreenState extends ConsumerState<HistorySettingsScreen> {
  List<String> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('oracle_history') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _deleteHistoryItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history.removeAt(index);
    });
    await prefs.setStringList('oracle_history', _history);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);
    final notifier = ref.read(userSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("PROTOKOL", style: AppTheme.orbitronStyle.copyWith(letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80), // Added bottom padding for nav bar as well
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. KİMLİK KARTI
            Text("KİMLİK VERİLERİ (GÜNCELLE)", style: TextStyle(color: AppTheme.neonCyan, letterSpacing: 1.2, fontSize: 12)),
            const SizedBox(height: 10),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildNeonInput(
                      label: "KOD ADI", 
                      value: settings.name, 
                      onChanged: notifier.updateName,
                      icon: Icons.person
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                         Expanded(child: _buildNeonInput(label: "BOY", value: settings.height, onChanged: notifier.updateHeight, icon: Icons.height)),
                         const SizedBox(width: 16),
                         Expanded(child: _buildNeonInput(label: "KİLO", value: settings.weight, onChanged: notifier.updateWeight, icon: Icons.monitor_weight)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. ARŞİVLER
            Text("ARŞİVLER (GEÇMİŞ)", style: TextStyle(color: AppTheme.neonPurple, letterSpacing: 1.2, fontSize: 12)),
            const SizedBox(height: 10),
            
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _history.isEmpty 
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(child: Text("Henüz kehanet kaydı yok...", style: GoogleFonts.inter(color: Colors.white30))),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      // History string format: "Question|Date" (Assumed for now, split if possible, else just show)
                      final itemText = _history[index];
                      // Simple split handling if pipe exists, else raw
                      final parts = itemText.contains('|') ? itemText.split('|') : [itemText, ''];
                      final q = parts[0];
                      final date = parts.length > 1 ? parts[1] : '';

                      return Dismissible(
                        key: Key(itemText), // Unique enough for this context
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) => _deleteHistoryItem(index),
                        background: Container(
                          color: AppTheme.errorRed.withOpacity(0.8), 
                          alignment: Alignment.centerRight, 
                          padding: const EdgeInsets.only(right: 20), 
                          child: const Icon(Icons.delete, color: Colors.white)
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            color: const Color(0xFF1A0033).withOpacity(0.4),
                            child: ListTile(
                              leading: Icon(Icons.history, color: Colors.white54),
                              title: Text(q, style: GoogleFonts.inter(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: date.isNotEmpty ? Text(date, style: GoogleFonts.inter(color: Colors.white30, fontSize: 10)) : null,
                              trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.neonPurple, size: 14),
                            ),
                          ),
                        ),
                      );
                    },
                  )
          ],
        ),
      ),
    );
  }

  Widget _buildNeonInput({required String label, required String value, required Function(String) onChanged, required IconData icon}) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      style: GoogleFonts.orbitron(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: AppTheme.neonCyan),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.neonCyan)),
      ),
    );
  }
}
