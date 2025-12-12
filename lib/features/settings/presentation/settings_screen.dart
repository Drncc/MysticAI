import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/user_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('oracle_history') ?? [];
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("AYARLAR", style: AppTheme.orbitronStyle.copyWith(letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.neonCyan,
          indicatorWeight: 3,
          labelColor: AppTheme.neonCyan,
          unselectedLabelColor: Colors.white54,
          labelStyle: AppTheme.orbitronStyle.copyWith(fontSize: 12),
          tabs: const [
            Tab(text: "KİMLİK"),
            Tab(text: "GEÇMİŞ"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: KİMLİK (Identity)
          _buildIdentityTab(),
          // TAB 2: GEÇMİŞ (Archives)
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildIdentityTab() {
    final settings = ref.watch(userSettingsProvider);
    final notifier = ref.read(userSettingsProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            color: const Color(0xFF1A0033).withOpacity(0.3),
            borderColor: AppTheme.neonPurple.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildNeonInput(
                    label: "AD SOYAD", 
                    value: settings.name, 
                    onChanged: notifier.updateName,
                    icon: Icons.person
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildNeonInput(label: "YAŞ", value: settings.age, onChanged: notifier.updateAge, icon: Icons.cake)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildNeonInput(label: "MESLEK", value: settings.profession, onChanged: notifier.updateProfession, icon: Icons.work)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildNeonInput(
                    label: "MEDENİ DURUM", 
                    value: settings.maritalStatus, 
                    onChanged: notifier.updateMaritalStatus,
                    icon: Icons.favorite
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildNeonInput(label: "BOY (cm)", value: settings.height, onChanged: notifier.updateHeight, icon: Icons.height)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildNeonInput(label: "KİLO (kg)", value: settings.weight, onChanged: notifier.updateWeight, icon: Icons.monitor_weight)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          GlassCard(
            color: const Color(0xFF001133).withOpacity(0.3),
            borderColor: AppTheme.neonCyan.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.star, color: AppTheme.neonCyan),
                    title: Text("BURÇ & DOĞUM TARİHİ", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      settings.zodiacSign.isNotEmpty ? "Burç: ${settings.zodiacSign}" : "Seçilmedi",
                      style: GoogleFonts.orbitron(color: AppTheme.neonCyan),
                    ),
                    trailing: Icon(Icons.calendar_today, color: Colors.white54),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: settings.birthDate ?? DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: AppTheme.neonPurple,
                                onPrimary: Colors.white,
                                surface: const Color(0xFF1A0033),
                              ),
                            ),
                            child: child!,
                          );
                        }
                      );
                      if (date != null) notifier.updateBirthDate(date);
                    },
                  ),
                  const Divider(color: Colors.white12),
                  SwitchListTile(
                    title: Text("Burç Yorumunu Kehanete Dahil Et", style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                    value: settings.includeZodiacInOracle,
                    activeColor: AppTheme.neonCyan,
                    onChanged: (val) => notifier.toggleZodiacInclusion(val),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          Center(
             child: ElevatedButton(
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppTheme.neonPurple.withOpacity(0.2),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: AppTheme.neonPurple)),
                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
               ),
               onPressed: () {
                 // Keyboard dismiss
                 FocusScope.of(context).unfocus();
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profil Güncellendi", style: GoogleFonts.orbitron()), backgroundColor: AppTheme.neonPurple));
               },
               child: Text("KAYDET", style: AppTheme.orbitronStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
             ),
          )
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, color: Colors.white24, size: 64),
            const SizedBox(height: 10),
            Text("Henüz bir kayıt yok...", style: GoogleFonts.inter(color: Colors.white30))
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final itemText = _history[index];
        final parts = itemText.contains('|') ? itemText.split('|') : [itemText, ''];
        final q = parts[0];
        
        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteHistoryItem(index),
          background: Container(
            color: Colors.red.withOpacity(0.5),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              color: const Color(0xFF0F0C29).withOpacity(0.5),
              child: ListTile(
                leading: const Icon(Icons.chat_bubble_outline, color: Colors.white54),
                title: Text(q, style: GoogleFonts.inter(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white24),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeonInput({required String label, required String value, required Function(String) onChanged, required IconData icon}) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
        prefixIcon: Icon(icon, color: AppTheme.neonPurple.withOpacity(0.7)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.neonCyan)),
      ),
    );
  }
}
