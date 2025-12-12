import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// User Settings State
class UserSettings {
  final String name;
  final String age;
  final String profession;
  final String maritalStatus;
  final String height;
  final String weight;
  final DateTime? birthDate;
  final String zodiacSign;
  final bool includeZodiacInOracle;

  UserSettings({
    this.name = '',
    this.age = '',
    this.profession = '',
    this.maritalStatus = '',
    this.height = '',
    this.weight = '',
    this.birthDate,
    this.zodiacSign = 'BİLİNMİYOR',
    this.includeZodiacInOracle = true,
  });

  UserSettings copyWith({
    String? name,
    String? age,
    String? profession,
    String? maritalStatus,
    String? height,
    String? weight,
    DateTime? birthDate,
    String? zodiacSign,
    bool? includeZodiacInOracle,
  }) {
    return UserSettings(
      name: name ?? this.name,
      age: age ?? this.age,
      profession: profession ?? this.profession,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      birthDate: birthDate ?? this.birthDate,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      includeZodiacInOracle: includeZodiacInOracle ?? this.includeZodiacInOracle,
    );
  }
}

// Notifier
class UserSettingsNotifier extends StateNotifier<UserSettings> {
  UserSettingsNotifier() : super(UserSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final age = prefs.getString('user_age') ?? '';
    final profession = prefs.getString('user_profession') ?? '';
    final maritalStatus = prefs.getString('user_marital_status') ?? '';
    final height = prefs.getString('user_height') ?? '';
    final weight = prefs.getString('user_weight') ?? '';
    final birthDateStr = prefs.getString('user_birth_date');
    final zodiac = prefs.getString('user_zodiac') ?? 'BİLİNMİYOR';
    final includeZodiac = prefs.getBool('user_include_zodiac') ?? true;

    DateTime? birthDate;
    if (birthDateStr != null) {
      birthDate = DateTime.tryParse(birthDateStr);
    }

    state = UserSettings(
      name: name,
      age: age,
      profession: profession,
      maritalStatus: maritalStatus,
      height: height,
      weight: weight,
      birthDate: birthDate,
      zodiacSign: zodiac,
      includeZodiacInOracle: includeZodiac,
    );
  }

  Future<void> updateName(String name) async {
    state = state.copyWith(name: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  Future<void> updateAge(String age) async {
    state = state.copyWith(age: age);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_age', age);
  }

  Future<void> updateProfession(String profession) async {
    state = state.copyWith(profession: profession);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profession', profession);
  }

  Future<void> updateMaritalStatus(String status) async {
    state = state.copyWith(maritalStatus: status);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_marital_status', status);
  }

  Future<void> updateHeight(String height) async {
    state = state.copyWith(height: height);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_height', height);
  }

  Future<void> updateWeight(String weight) async {
    state = state.copyWith(weight: weight);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_weight', weight);
  }

  Future<void> updateBirthDate(DateTime date) async {
    final zodiac = _calculateZodiac(date);
    state = state.copyWith(birthDate: date, zodiacSign: zodiac);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_birth_date', date.toIso8601String());
    await prefs.setString('user_zodiac', zodiac);
  }

  Future<void> toggleZodiacInclusion(bool value) async {
    state = state.copyWith(includeZodiacInOracle: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_include_zodiac', value);
  }

  String _calculateZodiac(DateTime date) {
    int day = date.day;
    int month = date.month;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return "KOÇ";
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return "BOĞA";
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return "İKİZLER";
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return "YENGEÇ";
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "ASLAN";
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return "BAŞAK";
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return "TERAZİ";
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return "AKREP";
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return "YAY";
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return "OĞLAK";
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return "KOVA";
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return "BALIK";
    return "BİLİNMİYOR";
  }
}

final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  return UserSettingsNotifier();
});
