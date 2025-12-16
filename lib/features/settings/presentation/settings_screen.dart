import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/user_settings_provider.dart';
import 'package:tekno_mistik/features/auth/presentation/login_screen.dart';
import 'package:tekno_mistik/core/i18n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _history = [];
  bool _isHistoryLoading = true;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', image.path);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // --- YARDIMCI METOTLAR ---
  
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawHistory = prefs.getStringList('oracle_chat_history') ?? [];
    
    if (mounted) {
      setState(() {
        _history = rawHistory.map((e) {
          try {
            return jsonDecode(e) as Map<String, dynamic>;
          } catch (_) {
            return {'question': e, 'answer': '', 'date': ''};
          }
        }).toList();
        _isHistoryLoading = false;
      });
    }
  }

  Future<void> _deleteHistoryItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history.removeAt(index);
    });
    
    final List<String> encodedList = _history.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('oracle_chat_history', encodedList);
  }

  Future<void> _logoutAndReset(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text("Sistem Kapatılıyor", style: AppTheme.orbitronStyle.copyWith(color: AppTheme.errorRed)),
        content: Text(
          "Tüm yerel verilerin, sohbet geçmişin ve kimliğin silinecek. Kozmik bağ koparılacak. Emin misin?", 
          style: GoogleFonts.inter(color: Colors.white70)
        ),
        actions: [
          TextButton(
            child: const Text("İPTAL", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("BAĞLANTIYI KES", style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Clear Data
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              // Navigate to Login
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- BUILD METODU ---
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(tr.translate('settings_title'), style: AppTheme.orbitronStyle.copyWith(letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.cyanAccent),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.neonCyan,
          indicatorWeight: 3,
          labelColor: AppTheme.neonCyan,
          unselectedLabelColor: Colors.white54,
          labelStyle: AppTheme.orbitronStyle.copyWith(fontSize: 12),
          tabs: [
            Tab(text: tr.translate('tab_identity')),
            Tab(text: tr.translate('tab_history')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIdentityTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // --- TAB WIDGETLARI ---

  Widget _buildIdentityTab() {
    final settings = ref.watch(userSettingsProvider);
    final notifier = ref.read(userSettingsProvider.notifier);
    final tr = AppLocalizations.of(context);

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
                   // PROFILE AVATAR
                   GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.neonCyan, width: 2),
                            boxShadow: [BoxShadow(color: AppTheme.neonCyan.withOpacity(0.3), blurRadius: 15)],
                            image: DecorationImage(
                              image: _profileImagePath != null
                                  ? FileImage(File(_profileImagePath!)) as ImageProvider
                                  : const AssetImage('assets/tarot/0_fool_1.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.neonPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildNeonInput(
                    label: tr.translate('label_name'), 
                    value: settings.name, 
                    onChanged: notifier.updateName,
                    icon: Icons.person
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildNeonInput(label: tr.translate('label_age'), value: settings.age, onChanged: notifier.updateAge, icon: Icons.cake)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildNeonInput(label: tr.translate('label_job'), value: settings.profession, onChanged: notifier.updateProfession, icon: Icons.work)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildNeonInput(
                    label: tr.translate('label_status'), 
                    value: settings.maritalStatus, 
                    onChanged: notifier.updateMaritalStatus,
                    icon: Icons.favorite
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildNeonInput(label: tr.translate('label_height'), value: settings.height, onChanged: notifier.updateHeight, icon: Icons.height)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildNeonInput(label: tr.translate('label_weight'), value: settings.weight, onChanged: notifier.updateWeight, icon: Icons.monitor_weight)),
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
                    title: Text(tr.translate('label_zodiac_dob'), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      settings.zodiacSign.isNotEmpty ? "${tr.translate('label_zodiac_prefix')} ${settings.zodiacSign}" : "Seçilmedi",
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
                    title: Text(tr.translate('switch_zodiac_comment'), style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
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
                 FocusScope.of(context).unfocus();
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profil Güncellendi", style: GoogleFonts.orbitron()), backgroundColor: AppTheme.neonPurple));
               },
               child: Text(tr.translate('btn_save'), style: AppTheme.orbitronStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
             ),
          ),

          // 5. BAĞLANTIYI KOPAR (ÇIKIŞ)
          const SizedBox(height: 40),
          Center(
            child: GestureDetector(
              onTap: () => _logoutAndReset(context),
              child: GlassCard(
                color: Colors.red.withOpacity(0.1),
                borderColor: Colors.red.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.power_settings_new, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(
                        tr.translate('btn_logout'), 
                        style: AppTheme.orbitronStyle.copyWith(color: Colors.red, fontSize: 12)
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          final question = item['question'] ?? 'Bilinmeyen Soru';
          final answer = item['answer'] ?? '';
          final dateStr = item['date'] ?? '';
          
          DateTime? date;
          if (dateStr.isNotEmpty) {
             date = DateTime.tryParse(dateStr);
          }
          final formattedDate = date != null 
              ? "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}" 
              : "";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              color: const Color(0xFF0F0C29).withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Expanded(
                           child: Text(
                             question, 
                             style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold), 
                             maxLines: 1, 
                             overflow: TextOverflow.ellipsis
                           ),
                         ),
                         // DELETE ACTION
                         Row(
                           children: [
                             Text(formattedDate, style: GoogleFonts.inter(color: Colors.white24, fontSize: 10)),
                             const SizedBox(width: 8),
                             IconButton(
                               icon: Icon(Icons.delete_outline, color: AppTheme.neonPurple.withOpacity(0.8), size: 20),
                               padding: EdgeInsets.zero,
                               constraints: const BoxConstraints(),
                               onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFF1E1E2C),
                                      title: Text("Kayıp Enerji", style: AppTheme.orbitronStyle.copyWith(color: Colors.white)),
                                      content: Text(
                                        "Bu mesajı evrenin mistik dokusu içinde kaybetmek istediğine emin misin?",
                                        style: GoogleFonts.inter(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text("VAZGEÇ", style: TextStyle(color: Colors.grey)),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        TextButton(
                                          child: const Text("YOK ET", style: TextStyle(color: Colors.redAccent)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteHistoryItem(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                               },
                             )
                           ],
                         )
                       ],
                     ),
                     if (answer.isNotEmpty) ...[
                       const SizedBox(height: 6),
                       Text(
                         answer,
                         style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
