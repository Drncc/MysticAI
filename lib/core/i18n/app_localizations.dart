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
      'open_cosmic_lab_btn': "KOZMİK LABORATUVARI AÇ", // FIXED
      'system_syncing_msg': "SİSTEM SENKRONİZE EDİLİYOR...",
      // Cosmic Lab
      'lab_title': "KOZMİK LABORATUVAR",
      'lab_subtitle': "Gizli kozmik araçlara erişim sağla.",
      'lab_love': "AŞK UYUMU",
      'lab_dream': "RÜYA TABİRİ",
      'lab_ritual': "RİTÜEL ODASI",
      'lab_share': "ENERJİ PAYLAŞ",
      // Prophecy Screen
      'prophecy_title': "KEHANET",
      'prophecy_seal_btn': "MÜHÜRLENİYOR...",
      'prophecy_listening': "EVREN DİNLİYOR...",
      'prophecy_seal_action': "ENERJİNİ KARTA MÜHÜRLE",
      'prophecy_limit_title': "Kader Mühürlendi",
      'prophecy_limit_msg': "Bugünlük kart hakkın doldu. Yarın gel veya Üstat seviyesine geç.",
      'prophecy_result_title': "KADERİN YANSIMASI",
      'prophecy_share_btn': "ENERJİYİ PAYLAŞ",
      'prophecy_close_btn': "MÜHRÜ KAPAT",
      'btn_understood': "ANLADIM",
      // Tarot Cards (Major Arcana)
      'tarot_fool_name': "Deli", 'tarot_fool_desc': "Başlangıçlar, masumiyet, spontanlık, özgür ruh.",
      'tarot_magician_name': "Büyücü", 'tarot_magician_desc': "Tezahür, beceriklilik, güç, ilham.",
      'tarot_highpriestess_name': "Azize", 'tarot_highpriestess_desc': "Sezgi, bilinçaltı, iç ses, gizem.",
      'tarot_theempress_name': "İmparatoriçe", 'tarot_theempress_desc': "Doğurganlık, dişilik, güzellik, doğa, bolluk.",
      'tarot_theemperor_name': "İmparator", 'tarot_theemperor_desc': "Otorite, yapı, kontrol, babalık.",
      'tarot_thehierophant_name': "Aziz", 'tarot_thehierophant_desc': "Gelenek, inanç, maneviyat, rehberlik.",
      'tarot_lovers_name': "Aşıklar", 'tarot_lovers_desc': "Aşk, uyum, ilişkiler, değerler.",
      'tarot_chariot_name': "Savaş Arabası", 'tarot_chariot_desc': "Kontrol, irade, başarı, eylem.",
      'tarot_strenght_name': "Güç", 'tarot_strenght_desc': "Güç, cesaret, sabır, kontrol.",
      'tarot_hermit_name': "Ermiş", 'tarot_hermit_desc': "İç gözlem, yalnızlık, rehberlik.",
      'tarot_wheeloffortune_name': "Kader Çarkı", 'tarot_wheeloffortune_desc': "Şans, karma, yaşam döngüleri, kader.",
      'tarot_justice_name': "Adalet", 'tarot_justice_desc': "Adalet, denge, gerçek, hukuk.",
      'tarot_hanged_name': "Asılan Adam", 'tarot_hanged_desc': "Teslimiyet, fedakarlık, yeni bakış açısı.",
      'tarot_death_name': "Ölüm", 'tarot_death_desc': "Sonlar, değişim, dönüşüm, geçiş.",
      'tarot_temperance_name': "Denge", 'tarot_temperance_desc': "Denge, ılımlılık, sabır, amaç.",
      'tarot_devil_name': "Şeytan", 'tarot_devil_desc': "Bağımlılık, maddiyat, cinsellik, gölge benlik.",
      'tarot_tower_name': "Yıkılan Kule", 'tarot_tower_desc': "Ani değişim, kaos, yıkım, uyanış.",
      'tarot_star_name': "Yıldız", 'tarot_star_desc': "Umut, inanç, amaç, yenilenme.",
      'tarot_moon_name': "Ay", 'tarot_moon_desc': "Yanılsama, korku, kaygı, bilinçaltı.",
      'tarot_sun_name': "Güneş", 'tarot_sun_desc': "Pozitiflik, eğlence, sıcaklık, başarı.",
      'tarot_judgement_name': "Mahkeme", 'tarot_judgement_desc': "Yargı, yeniden doğuş, iç çağrı.",
      'tarot_world_name': "Dünya", 'tarot_world_desc': "Tamamlanma, entegrasyon, başarı, seyahat.",
      'oracle_limit_title': "Kahin Yoruldu",
      'oracle_limit_msg': "Günlük soru limitine ulaştın. Daha fazlası için kozmik enerjini yükselt.",
      // Store / Cosmic Access
      'store_title': "KOZMİK ERİŞİM",
      'store_subtitle': "Evrenin sırlarına sınırsız erişim sağla.\nKaderini şekillendir.",
      'feature_oracle': "Günde 15 Detaylı Oracle Mesajı",
      'feature_tarot': "Günde 3 Tarot Kartı Açılımı",
      'feature_astro': "Detaylı Burç & Astro Analizi",
      'feature_ads': "Reklamsız Mistik Deneyim",
      'pkg_apprentice': "ÇIRAK",
      'pkg_apprentice_price': "₺49.99 / Hafta",
      'pkg_apprentice_sub': "(Başlangıç İçin)",
      'pkg_oracle': "KAHİN",
      'pkg_oracle_price': "₺149.99 / Ay",
      'pkg_oracle_sub': "(En Popüler Seçim)",
      'pkg_master': "ÜSTAT",
      'pkg_master_price': "₺999.99 / Yıl",
      'pkg_master_sub': "(Aylık sadece 83₺)",
      'store_btn_upgrade': "SEÇİMİ ONAYLA VE YÜKSEL",
      'store_badge_popular': "POPÜLER",
      'store_badge_social': "10.000+ Gezginin Tercihi",
      'store_legal': "İptal edilebilir. Gizlilik politikası geçerlidir.",
      'store_success': "Yükseliş Tamamlandı. Sınırlar Kalktı.",
      // Oracle & hints
      'oracle_placeholder': "Kehanet için sorunu yönelt...",
      'input_hint': "Sorunu Yaz...",
      // Oracle Chips
      'chip_energy': "Bugün enerjim nasıl?",
      'chip_love': "Aşk hayatımda neler olacak?",
      'chip_career': "Kariyerimde yükseliş var mı?",
      'chip_dream': "Rüyamda yılan gördüm, anlamı ne?",
      'chip_chakra': "Hangi çakram tıkalı?",
      'chip_soulmate': "Ruh eşimle ne zaman tanışacağım?",
      // Dashboard Logic
      'status_storm': "Fırtına: Başın ağrıyabilir.",
      'status_calm': "Sakin: Enerji akışı temiz.",
      'status_stable_meditation': "Stabil: Meditasyon için uygun.",
      'status_low_flux': "Düşük Akı: İçe dönmek için ideal.",
      'status_high_energy': "Yüksek Enerji: Ani kararlardan kaçın.",
      'status_balanced_flux': "Dengeli Akış: Üretkenlik için uygun.",
      'status_turbulence': "Türbülans: Risk alma.",
      'status_stable_aligned': "Stabil: Evren seninle uyumlu.",
      'lunar_growing': "Yeni başlangıçlar zamanı.",
      'lunar_shrinking': "Arınma zamanı.",
      'moon_waxing': "BÜYÜYEN",
      'moon_waning': "KÜÇÜLEN",
      // Subconscious Scanner (Dream)
      'dream_title': "BİLİNÇALTI TARAYICI",
      'dream_subtitle': "Rüyalar, ruhun fısıltılarıdır.\nGördüklerini anlat, sembolleri çözelim.",
      'dream_hint': "Örn: Bir ormanda kayboldum...",
      'btn_decode': "SİMGELERİ ÇÖZ", // User key
      'btn_decode_symbols': "SİMGELERİ ÇÖZ", // Legacy key
      // Cosmic Compatibility
      'comp_title': "KOZMİK UYUM",
      'compatibility_title': "KOZMİK UYUM", // Legacy key
      'label_your_sign': "Senin Burcun",
      'label_partner_sign': "Partnerin Burcu",
      'btn_analyze': "ANALİZ ET",
      // Settings / Profile
      'settings_title': "AYARLAR",
      'tab_identity': "KİMLİK",
      'tab_history': "GEÇMİŞ",
      'label_name': "AD SOYAD",
      'label_age': "YAŞ",
      'label_job': "MESLEK",
      'label_status': "MEDENİ DURUM",
      'label_height': "BOY (cm)",
      'label_weight': "KİLO (kg)",
      'label_zodiac_dob': "BURÇ & DOĞUM TARİHİ",
      'label_zodiac_prefix': "Burç:",
      'switch_zodiac_comment': "Burç Yorumunu Kehanete Dahil Et",
      'btn_save': "KAYDET",
      'btn_logout': "BAĞLANTIYI KOPAR (ÇIKIŞ)",
      'oracle_limit_title': "Kahin Yoruldu",
      'oracle_limit_msg': "Günlük soru limitine ulaştın. Daha fazlası için kozmik enerjini yükselt.",
      // Store / Cosmic Access
      'store_title': "KOZMİK ERİŞİM",
      'store_subtitle': "Evrenin sırlarına sınırsız erişim sağla.\nKaderini şekillendir.",
      'plan_apprentice': "ÇIRAK",
      'plan_oracle': "KAHİN",
      'plan_master': "ÜSTAT",
      'btn_subscribe': "SEÇİMİ ONAYLA VE YÜKSEL",
      'pkg_apprentice': "ÇIRAK", // Legacy
      'pkg_apprentice_price': "₺49.99 / Hafta",
      'pkg_apprentice_sub': "(Başlangıç İçin)",
      'pkg_oracle': "KAHİN", // Legacy
      'pkg_oracle_price': "₺149.99 / Ay",
      'pkg_oracle_sub': "(En Popüler Seçim)",
      'pkg_master': "ÜSTAT", // Legacy
      'pkg_master_price': "₺999.99 / Yıl",
      'pkg_master_sub': "(Aylık sadece 83₺)",
      'store_btn_upgrade': "SEÇİMİ ONAYLA VE YÜKSEL", // Legacy
      'store_badge_popular': "POPÜLER",
      'store_badge_social': "10.000+ Gezginin Tercihi",
      'store_legal': "İptal edilebilir. Gizlilik politikası geçerlidir.",
      'store_success': "Yükseliş Tamamlandı. Sınırlar Kalktı.",
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
      'open_cosmic_lab_btn': "OPEN COSMIC LAB",
      'system_syncing_msg': "SYSTEM IS SYNCHRONIZING...",
      // Cosmic Lab
      'lab_title': "COSMIC LAB",
      'lab_subtitle': "Access hidden cosmic tools.",
      'lab_love': "LOVE MATCH",
      'lab_dream': "DREAM INTERPRETER",
      'lab_ritual': "RITUAL ROOM",
      'lab_share': "SHARE ENERGY",
      // Prophecy Screen
      'prophecy_title': "PROPHECY",
      'prophecy_seal_btn': "SEALING...",
      'prophecy_listening': "UNIVERSE IS LISTENING...",
      'prophecy_seal_action': "SEAL YOUR ENERGY",
      'prophecy_limit_title': "Fate Sealed",
      'prophecy_limit_msg': "You have used your daily card. Return tomorrow or ascend to Master level.",
      'prophecy_result_title': "REFLECTION OF FATE",
      'prophecy_share_btn': "SHARE ENERGY",
      'prophecy_close_btn': "CLOSE SEAL",
      'btn_understood': "UNDERSTOOD",
      // Tarot Cards (Major Arcana)
      'tarot_fool_name': "The Fool", 'tarot_fool_desc': "Beginnings, innocence, spontaneity, a free spirit.",
      'tarot_magician_name': "The Magician", 'tarot_magician_desc': "Manifestation, resourcefulness, power, inspired action.",
      'tarot_highpriestess_name': "High Priestess", 'tarot_highpriestess_desc': "Intuition, sacred knowledge, divine feminine, the subconscious mind.",
      'tarot_theempress_name': "The Empress", 'tarot_theempress_desc': "Femininity, beauty, nature, nurturing, abundance.",
      'tarot_theemperor_name': "The Emperor", 'tarot_theemperor_desc': "Authority, establishment, structure, a father figure.",
      'tarot_thehierophant_name': "The Hierophant", 'tarot_thehierophant_desc': "Spiritual wisdom, religious beliefs, conformity, tradition.",
      'tarot_lovers_name': "The Lovers", 'tarot_lovers_desc': "Love, harmony, relationships, values alignment, choices.",
      'tarot_chariot_name': "The Chariot", 'tarot_chariot_desc': "Control, willpower, success, action, determination.",
      'tarot_strenght_name': "Strength", 'tarot_strenght_desc': "Strength, courage, persuasion, influence, compassion.",
      'tarot_hermit_name': "The Hermit", 'tarot_hermit_desc': "Soul-searching, introspection, being alone, inner guidance.",
      'tarot_wheeloffortune_name': "Wheel of Fortune", 'tarot_wheeloffortune_desc': "Good luck, karma, life cycles, destiny, a turning point.",
      'tarot_justice_name': "Justice", 'tarot_justice_desc': "Justice, fairness, truth, cause and effect, law.",
      'tarot_hanged_name': "The Hanged Man", 'tarot_hanged_desc': "Pausing, surrender, letting go, new perspectives.",
      'tarot_death_name': "Death", 'tarot_death_desc': "Endings, change, transformation, transition.",
      'tarot_temperance_name': "Temperance", 'tarot_temperance_desc': "Balance, moderation, patience, purpose.",
      'tarot_devil_name': "The Devil", 'tarot_devil_desc': "Shadow self, attachment, addiction, restriction, sexuality.",
      'tarot_tower_name': "The Tower", 'tarot_tower_desc': "Sudden change, upheaval, chaos, revelation, awakening.",
      'tarot_star_name': "The Star", 'tarot_star_desc': "Hope, faith, purpose, renewal, spirituality.",
      'tarot_moon_name': "The Moon", 'tarot_moon_desc': "Illusion, fear, anxiety, subconscious, intuition.",
      'tarot_sun_name': "The Sun", 'tarot_sun_desc': "Positivity, fun, warmth, success, vitality.",
      'tarot_judgement_name': "Judgement", 'tarot_judgement_desc': "Judgement, rebirth, inner calling, absolution.",
      'tarot_world_name': "The World", 'tarot_world_desc': "Completion, integration, accomplishment, travel.",
      'oracle_limit_title': "Oracle Exhausted",
      'oracle_limit_msg': "Daily question limit reached. Ascend your cosmic energy for more.",
      // Store / Cosmic Access
      'store_title': "COSMIC ACCESS",
      'store_subtitle': "Get unlimited access to the secrets of the universe.",
      'feature_oracle': "15 Detailed Oracle Messages / Day",
      'feature_tarot': "3 Tarot Card Readings / Day",
      'feature_astro': "Detailed Horoscope & Astro Analysis",
      'feature_ads': "Ad-Free Mystic Experience",
      'plan_apprentice': "APPRENTICE",
      'plan_oracle': "SEER",
      'plan_master': "MASTER",
      'btn_subscribe': "CONFIRM & ASCEND",
      'pkg_apprentice': "APPRENTICE", // Legacy
      'pkg_apprentice_price': "₺49.99 / Week",
      'pkg_apprentice_sub': "(For Beginners)",
      'pkg_oracle': "SEER", // Updated to match user request "SEER"
      'pkg_oracle_price': "₺149.99 / Month",
      'pkg_oracle_sub': "(Most Popular Choice)",
      'pkg_master': "MASTER", // Legacy
      'pkg_master_price': "₺999.99 / Year",
      'pkg_master_sub': "(Only 83₺/Month)",
      'store_btn_upgrade': "CONFIRM & ASCEND", // Legacy
      'store_badge_popular': "POPULAR",
      'store_badge_social': "Preferred by 10,000+ Voyagers",
      'store_legal': "Cancel anytime. Privacy policy applies.",
      'store_success': "Ascension Complete. Limits Removed.",
      // Oracle & hints
      'oracle_hint': "Ask for prophecy...",
      'oracle_placeholder': "Ask your question to the Oracle...",
      'input_hint': "Type your question...",
      // Oracle Chips
      'chip_energy': "How is my energy today?",
      'chip_love': "What will happen in my love life?",
      'chip_career': "Is there a rise in my career?",
      'chip_dream': "I saw a snake in my dream, what does it mean?",
      'chip_chakra': "Which chakra is blocked?",
      'chip_soulmate': "When will I meet my soulmate?",
      // Dashboard Logic
      'status_storm': "Storm: You may experience headaches.",
      'status_calm': "Calm: Clean energy flow.",
      'status_stable_meditation': "Stable: Suitable for meditation.",
      'status_low_flux': "Low Flux: Ideal for turning inward.",
      'status_high_energy': "High Energy: Avoid rash decisions.",
      'status_balanced_flux': "Balanced Flux: Good for productivity.",
      'status_turbulence': "Turbulence: Do not take risks.",
      'status_stable_aligned': "Stable: The universe is aligned with you.",
      'lunar_growing': "Time for new beginnings.",
      'lunar_shrinking': "Time for cleansing.",
      'moon_waxing': "WAXING",
      'moon_waning': "WANING",
      // Subconscious Scanner (Dream)
      'dream_title': "SUBCONSCIOUS SCANNER",
      'dream_subtitle': "Dreams are whispers of the soul.\nDescribe what you saw, let's decode symbols.",
      'dream_hint': "Ex: I got lost in a forest...",
      'btn_decode': "DECODE SYMBOLS",
      'btn_decode_symbols': "DECODE SYMBOLS", // Legacy
      // Compatibility Screen (Love)
      'comp_title': "COSMIC COMPATIBILITY",
      'compatibility_title': "COSMIC COMPATIBILITY", // Legacy
      'label_your_sign': "Your Zodiac",
      'label_partner_sign': "Partner's Zodiac",
      'btn_analyze': "ANALYZE",
      // Settings / Profile
      'settings_title': "SETTINGS",
      'tab_identity': "IDENTITY",
      'tab_history': "HISTORY",
      'label_name': "FULL NAME",
      'label_age': "AGE",
      'label_job': "PROFESSION",
      'label_status': "MARITAL STATUS",
      'label_height': "HEIGHT (cm)",
      'label_weight': "WEIGHT (kg)",
      'label_zodiac_dob': "ZODIAC & BIRTH DATE",
      'label_zodiac_prefix': "Zodiac:",
      'switch_zodiac_comment': "Include Zodiac Interpretation in Prophecy",
      'btn_save': "SAVE",
      'btn_logout': "DISCONNECT (LOGOUT)",
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
