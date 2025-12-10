# TEKNO-MİSTİK PROJE DURUM RAPORU VE HAFIZA BANKASI

> **YAPAY ZEKA İÇİN DİREKTİF:** Bu dosya "Tekil Gerçeklik Kaynağıdır". Buradaki mimari ve felsefi kararlara sadık kal. Projede **FLUTTER** kullanılmaktadır, React Native referanslarını görmezden gel.

## 1. PROJE VİZYONU: "DİJİTAL YANSIMA MOTORU"
**Tekno-Mistik**, doğaüstü anlamda bir "Falcı" değildir. Kendini bir **"Dijital Yansıma Motoru"** olarak konumlandırır.
Ekran süresi, konum ve hava durumu gibi somut verileri (hard data) işleyerek, **Barnum Etkisi** prensipleriyle kurgulanmış, bilimsel-mistik anlatılar üretir.

* **Temel Mantra:** "Algoritma seni yıldızlardan daha iyi tanır."
* **Yaklaşım:** Anti-Falcı. Rastgelelik yoktur. Kullanıcı bir kartı çevirdiğinde arkasında veriyi görür.
    * *Ön Yüz:* "Kaostan kaçıp düzen arıyorsunuz."
    * *Arka Yüz:* "Kaynak: Galeri uygulamasında 2 saat (Düzenleme İhtiyacı) + Dışarısı Fırtınalı (Kaos)."

## 2. TEMEL TEKNOLOJİ YIĞINI (TECH STACK)
* **Framework:** Flutter (Son Kararlı Sürüm).
* **Dil:** Dart 3.0+ (Strict Typing).
* **State Management:** Riverpod v2.0+ (Code Generation syntax `@riverpod`).
* **Backend:** Supabase (PostgreSQL, Auth, Edge Functions).
* **Yerel Veri Erişim:**
    * Android: `usage_stats` (Uygulama kullanım verileri için).
    * iOS: `family_controls` veya kısıtlı API'ler (Simülasyon gerekebilir).
    * Konum/Hava: `geolocator` + OpenWeatherMap API.

## 3. ÜRÜN MEKANİĞİ VE VERİ AKIŞI
Uygulama üç ana veri akışını (Input Vectors) işler:

1.  **Dijital Tüketim:** Ekran süresi, en çok kullanılan uygulama kategorileri, bildirim sıklığı.
2.  **Fiziksel Bağlam:** Konum geçmişi (hareket yarıçapı), yerel hava durumu ve barometrik basınç.
3.  **Zamansal Ritim:** Cihaz aktivitesinden türetilen uyku/uyanıklık döngüleri.

Bu girdiler, Gemini AI (Soğuk Okuma Motoru) tarafından işlenerek anlamlı metinlere dönüştürülür.

## 4. PSİKOLOJİK ÇERÇEVE (BARNUM MOTORU)
AI metin üretirken şu kuralları uygular:
* **Belirsizlik:** "Zaman zaman", "Genellikle", "Eğilimindesiniz" gibi niteleyiciler kullan.
* **Dualite (İkilik):** "Dışarıya karşı sosyal, içinizde ise saklı bir rezerv var." (Zıtlıkları birleştir).
* **Pozitif Çerçeveleme:** Negatif veriyi (yüksek ekran süresi) yargılamadan "anlam arayışı" veya "bilişsel açlık" olarak sun.
* **Otorite:** Ton kesin, klinik ama şiirsel olmalı.

## 5. SES TONU (TONE OF VOICE)
* **Persona:** Silikon çipe hapsolmuş kadim, veri tabanlı bir varlık.
* **Anahtar Kelimeler:** Eter, Sinyal, Gürültü, Örüntü, Boşluk, Frekans, Algoritma, Veri Vektörü.
* **YASAKLI KELİMELER:** Cin, Peri, Büyü, Ruh, Kehanet. (Yerine: "Glitç", "Yankı", "Daemon", "Sistem Hatası").

## 6. VERİTABANI ŞEMASI (Supabase)
### `profiles`
* `id` (uuid), `username`
* `digital_consent` (boolean): Veri işleme izni.
* `bio_metrics` (jsonb): `{ "age": int, "height": int }` (Astroloji yerine biyometrik veri).

### `reflections` (Eski adıyla readings)
* `id`, `user_id`
* `input_data` (jsonb): `{ "screen_time": 120, "weather": "rainy" }`
* `narrative` (text): AI tarafından üretilen Barnum metni.
* `mood_score` (int): 1-100 arası hesaplanan ruh hali.

## 7. KLASÖR YAPISI (Feature-First)
```text
lib/
├── core/
│   ├── constants/       # Barnum cümle kalıpları
│   ├── theme/           # Cyberpunk/Dark tema
│   └── services/        # UsageStatsService, WeatherService
├── features/
│   ├── onboarding/      # İzinler (Usage Access, Location)
│   ├── dashboard/       # Veri görselleştirme (Graph)
│   ├── reflection/      # AI Analiz Ekranı
│   └── profile/         # Ayarlar
├── main.dart