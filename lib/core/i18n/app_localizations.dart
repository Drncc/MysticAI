import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Locale Provider ---
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('tr', 'TR')); // Default TR

  void switchLanguage(Locale newLocale) {
    print('DEBUG: Switching language to $newLocale');
    state = newLocale;
  }
}

// --- App Localizations ---
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      'welcome_title': "HOŞ GELDİN,\nMÜHENDİS",
      'moon_phase_label': "KOZMİK YANSIMA",
      'moon_phase_desc': "Slowly expanding outwards.", // EN in instructions, but keeping context
      'resonance_label': "RUHSAL REZONANS",
      'resonance_desc': "DURGUN",
      'solar_activity_label': "BİYO-RİTİM",
      'solar_activity_desc': "Stable", // Keeping data content
      'local_data_signals': "ANLIK VERİ AKIŞI",
      'magnetic_flux_label': "Manyetik Akı",
      'magnetic_flux_hint': "Düşük akı için ölçüm için ideal.",
      'entropy_label': "DİJİTAL ENTROPİ",
      'entropy_desc': "Stable: Universe is aligned.",
      'open_cosmic_lab_btn': "OPEN COSMIC LAB",
      'system_syncing_msg': "SİSTEM SENKRONİZE EDİLİYOR...",
    },
    'en': {
      'welcome_title': "WELCOME,\nENGINEER",
      'moon_phase_label': "COSMIC REFLECTION", // Closest translation to KOZMİK YANSIMA/MOON PHASE context
      'moon_phase_desc': "Slowly expanding outwards.",
      'resonance_label': "SPIRITUAL RESONANCE",
      'resonance_desc': "STAGNANT", // Translation for DURGUN
      'solar_activity_label': "BIO-RHYTHM",
      'solar_activity_desc': "Stable",
      'local_data_signals': "LOCAL DATA SIGNALS",
      'magnetic_flux_label': "Magnetic Flux",
      'magnetic_flux_hint': "Ideal for low-flux measurements.",
      'entropy_label': "DIGITAL ENTROPY",
      'entropy_desc': "Stable: Universe is aligned.",
      'open_cosmic_lab_btn': "OPEN COSMIC LAB",
      'system_syncing_msg': "SYSTEM IS SYNCHRONIZING...",
    }
  };
  
  // Extra mapping for the strict requested ones in case of mismatch
  /*
  Strict Map Request vs Actual App Usage:
  Request: 'moon_phase_label' -> "MOON PHASE"
  App: Uses "KOZMİK YANSIMA" (Cosmic Reflection) for the ritual card.
  Action: I will blindly follow the requested English values where they match the keys, 
  but map them to the existing UI context. 
  
  The user requested: 
  welcome_title: "WELCOME, MÜHENDİS" / "WELCOME, ENGINEER"
  
  I will adjust the map below to STRICTLY match the User Request for the values, 
  but I must map them to what the app *actually displays* in Turkish currently 
  to ensure visual integrity before the switch.
  
  Current App: "HOŞ GELDİN,\nGEZGİN." ->  User wants: "WELCOME, MÜHENDİS" (Changed content)
  Current App: "RUHSAL REZONANS" -> User wants: "RESONANCE" (Changed content)
  
  CRITICAL: The user said "preserve visual integrity... except for the text content itself".
  So I should use the User's provided text.
  */

  static final Map<String, Map<String, String>> _strictLocalizedValues = {
    'tr': {
      'welcome_title': "HOŞ GELDİN,\nMÜHENDİS", 
      'moon_phase_label': "KOZMİK YANSIMA",
      'resonance_label': "RUHSAL REZONANS",
      'solar_activity_label': "BİYO-RİTİM",
      'local_data_signals': "ANLIK VERİ AKIŞI",
      'magnetic_flux_label': "Manyetik Akı",
      'entropy_label': "DİJİTAL ENTROPİ",
      // Navigation
      'nav_data': "VERİ AKIŞI",
      'nav_oracle': "ORACLE",
      'nav_store': "KOZMİK MAĞAZA",
      'nav_prophecy': "KEHANET",
      'nav_social': "TOPLULUK",
      // Data Stream
      'welcome_simple': "HOŞGELDİN,",
      'data_stream_title': "YEREL VERİ SİNYALLERİ",
      'moon_phase_title': "AY FAZI",
      'resonance_title': "REZONANS",
      'solar_activity_title': "SOLAR AKTİVİTE",
    },
    'en': {
      'welcome_title': "WELCOME,\nENGINEER",
      'moon_phase_label': "MOON PHASE",
      'resonance_label': "RESONANCE",
      'solar_activity_label': "SOLAR ACTIVITY",
      'local_data_signals': "LOCAL DATA SIGNALS",
      'magnetic_flux_label': "MAGNETIC FLUX",
      'entropy_label': "UNIVERSAL ENTROPY",
      // Navigation
      'nav_data': "DATA STREAM",
      'nav_oracle': "ORACLE",
      'nav_store': "COSMIC STORE",
      'nav_prophecy': "PROPHECY",
      'nav_social': "COMMUNITY",
      // Data Stream
      'welcome_simple': "WELCOME,",
      'data_stream_title': "LOCAL DATA SIGNALS",
      'moon_phase_title': "MOON PHASE",
      'resonance_title': "RESONANCE",
      'solar_activity_title': "SOLAR ACTIVITY",
    }
  };

  String translate(String key) {
    return _strictLocalizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['tr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
