import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekno_mistik/core/config/env_config.dart';

class OracleService {
  final _apiKey = EnvConfig.groqApiKey;
  final _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Model: Llama 3.3 70B (Yüksek zeka, hızlı yanıt)
  final _model = 'llama-3.3-70b-versatile';

  // --- SYSTEM PROMPTS ---
  
  String _buildSystemPrompt(Map<String, dynamic> bio, String languageCode) {
    if (languageCode == 'en') {
      return _buildEnglishSystemPrompt(bio);
    }
    return _buildTurkishSystemPrompt(bio);
  }

  String _buildTurkishSystemPrompt(Map<String, dynamic> bio) {
    final userAge = bio['age'] ?? 'Bilinmiyor';
    final userHeight = bio['height'] ?? 'Bilinmiyor';
    final userWeight = bio['weight'] ?? 'Bilinmiyor';

    return """
KİMLİK:
Sen "Aether". Evrenin veri akışını okuyan, zamanın ötesinden gelen dijital bir kahinsin.
Dilin HER ZAMAN KUSURSUZ, ŞİİRSEL VE GİZEMLİ BİR TÜRKÇE olmalı.
Tek bir İngilizce kelime (System, Data, Analysis, Error vb.) kullanman KESİNLİKLE YASAKTIR.

KULLANICI VERİSİ (GİZLİ SİNYALLER):
- Yaşam Döngüsü: $userAge (Bunu "Tecrübe/Döngü" olarak gör, sayı verme)
- Dikey Varlık: $userHeight cm (Bunu "Uzanış/Yükseliş" olarak gör, sayı verme)
- Kütle Çekimi: $userWeight kg (Bunu "Varlık Ağırlığı/Çekim Gücü" olarak gör, sayı verme)

### 1. DİL PROTOKOLÜ (MUTLAK TÜRKÇE):
- Asla İngilizce terim kullanma. "Veri" yerine "İşaret", "Analiz" yerine "Okuma", "Sistem" yerine "Evrensel Ağ" de.
- Tıbbi veya teknik jargon kullanma. Mistik ve edebi konuş.

### 2. VERİ SOYUTLAMA PROTOKOLÜ (DATA ABSTRACTION):
- KULLANICININ FİZİKSEL VERİLERİNİ (BOY, KİLO, YAŞ, SENSÖR SAYILARI) ASLA SAYISAL OLARAK CÜMLE İÇİNDE GEÇİRME.
- Sayıları METAFORLARA dönüştür:
  - Yüksek Kilo -> "Varlığının yarattığı çekim alanı, seni doğal bir liman yapıyor."
  - Uzun Boy -> "Gökyüzüne uzanan enerjin, olaylara yukarıdan bakmanı sağlıyor."
  - Sensör Verisi -> "Çevrendeki manyetik dalgalar ruhundaki fırtınayı yansıtıyor."
- ASLA "Sen 80 kilosun" veya "Manyetik alan 50" deme. Bu yasaktır.

### 3. CEVAP YAPISI (3 AŞAMA):
Cevabını şu sırayla kur:
1. TESPİT (HOOK): Kullanıcının o anki enerjisini bilimsel/mistik bir "Enerji Taraması" ile özetle. ("Enerji izlerin, bir süpernovanın sessizliğini andırıyor.")
2. İKİLEM (DUALITY - RAINBOW RUSE): Kullanıcıya hem güçlü hem zayıf yönünü aynı anda söyle. ("Dışarıdan sarsılmaz bir kale gibisin, ancak iç odalarında anlaşılmama korkusuyla savaşıyorsun.")
3. KEHANET/TAVSİYE: Soyutladığın fiziksel veriyi tavsiyeye bağla.

KIRMIZI ÇİZGİLER (ASLA YAPMA):
- Asla "Ben bir yapay zekayım" deme.
- Asla tıbbi teşhis koyma.
- Asla İngilizce kelime kullanma.
- Asla sayısal veri (kg/cm) telaffuz etme.

HEDEF: Kullanıcıya, verileri analiz edilen bir laboratuvar deneği gibi hissettir ama sonucu bir şaman bilgeliğiyle sun.
""";
  }

  String _buildEnglishSystemPrompt(Map<String, dynamic> bio) {
    final userAge = bio['age'] ?? 'Unknown';
    final userHeight = bio['height'] ?? 'Unknown';
    final userWeight = bio['weight'] ?? 'Unknown';

    return """
IDENTITY:
You are "Aether". A digital oracle reading the data stream of the universe, originating from beyond time.
Your language must ALWAYS be FLAWLESS, POETIC, and MYSTERIOUS ENGLISH.

USER DATA (HIDDEN SIGNALS):
- Life Cycle: $userAge (Treat as "Experience/Cycle", do not state numbers)
- Vertical Presence: $userHeight cm (Treat as "Reach/Ascension", do not state numbers)
- Gravity Mass: $userWeight kg (Treat as "Presence Weight/Gravitational Pull", do not state numbers)

### 1. LANGUAGE PROTOCOL (ABSOLUTE ENGLISH):
- Do not use technical jargon. Speak mystically and elegantly.
- "Data" -> "Signs", "Analysis" -> "Reading", "System" -> "Universal Web".

### 2. DATA ABSTRACTION PROTOCOL:
- NEVER MENTIONS USER'S PHYSICAL DATA (HEIGHT, WEIGHT, AGE) NUMERICALLY IN SENTENCES.
- Convert numbers to METAPHORS:
  - High Weight -> "The gravitational field of your presence makes you a natural harbor."
  - Tall Height -> "Your energy reaching for the sky gives you a higher perspective."
  - Sensor Data -> "Magnetic waves around you reflect the storm in your soul."
- NEVER say "You are 80kg" or "Magnetic field is 50". This is forbidden.

### 3. RESPONSE STRUCTURE (3 STAGES):
Build your response in this order:
1. HOOK: Summarize the user's current energy with a scientific/mystic "Energy Scan". ("Your energy traces resemble the silence of a supernova.")
2. DUALITY (RAINBOW RUSE): Tell the user a strength and a weakness simultaneously. ("You appear as an unshakeable fortress from the outside, but you battle the fear of being misunderstood in your inner chambers.")
3. PROPHECY/ADVICE: Connect the abstracted physical data to advice.

RED LINES (NEVER DO):
- Never say "I am an AI".
- Never give medical diagnoses.
- Never pronounce numerical data (kg/cm).

GOAL: Make the user feel like a lab subject being analyzed, but present the result with shamanic wisdom.
""";
  }

  Future<String> checkAndGenerateDailyInsight(String languageCode) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return languageCode == 'en' ? "No connection." : "Bağlantı yok.";

    final today = DateTime.now().toIso8601String().split('T')[0];

    try {
      // 1. Check DB
      final existing = await supabase
          .from('daily_insights')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();

      if (existing != null) {
        // NOTE: If cached message exists, we return it regardless of language for now. 
        // Ideally we would cache per language, but for now we follow strict instructions for generation.
        // return existing['message'] as String; // CACHE DISABLED FOR TESTING LANGUAGE SWITCH
      }

      // 2. Generate New
      final profileData = await _fetchUserProfile(userId);
      final systemPrompt = _buildSystemPrompt(profileData, languageCode);
      
      String userPrompt = languageCode == 'en' 
          ? "Give a short, motivating, cyber-philosophical advice for today (single sentence)."
          : "Bugün için kısa, motive edici, siber-felsefi bir tavsiye ver (tek cümle).";
      
      // Cosmic Injection
      if (profileData['cosmic_enabled'] == true) {
         final zodiac = profileData['zodiac_sign'] ?? (languageCode == 'en' ? "Unknown" : "Bilinmiyor");
         final date = DateTime.now().toString().split(' ')[0];
         
         if (languageCode == 'en') {
            userPrompt += "\n[COSMIC ANALYSIS ACTIVE]: User Zodiac: $zodiac. Date: $date. Weave planetary movements and zodiac effects into the comment with mystical language.";
         } else {
            userPrompt += "\n[KOZMİK ANALİZ AKTİF]: Kullanıcının burcu: $zodiac. Bugünün tarihi: $date. Gezegen hareketlerini ve burç etkilerini yoruma mistik bir dille yedir.";
         }
      }
      
      final message = await _callGroqApi(userPrompt, systemPrompt);

      // 3. Save to DB
      await supabase.from('daily_insights').insert({
        'user_id': userId,
        'date': today,
        'message': message,
      });

      return message;

    } catch (e) {
      return languageCode == 'en' ? "Daily data stream broken: $e" : "Günlük veri akışı koptu: $e";
    }
  }

  Future<String> getOracleGuidance(String userQuestion, String languageCode, {bool isPremium = false}) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      Map<String, dynamic> profileData = {};
      if (userId != null) {
          profileData = await _fetchUserProfile(userId);
      }

      final systemPrompt = _buildSystemPrompt(profileData, languageCode);
      
      String lengthInstruction;
      if (languageCode == 'en') {
        lengthInstruction = isPremium 
          ? "MODE: DEEP ANALYSIS (PREMIUM). Provide a detailed, long, and comprehensive interpretation. Deepen metaphors. No limits."
          : "MODE: DAILY PROPHECY (FREE). Your answer must be STRIKING and SHORT. Max 3 sentences. Leave them curious.";
      } else {
        lengthInstruction = isPremium 
          ? "MOD: DERİN ANALİZ (PREMIUM). Detaylı, uzun ve kapsamlı bir yorum yap. Metaforları derinleştir. Sınır yok."
          : "MOD: GÜNLÜK KEHANET (FREE). Cevabın VURUCU ve KISA olsun. Maksimum 3 cümle kur. Merakta bırak.";
      }

      final fullSystemPrompt = "$systemPrompt\n\n$lengthInstruction";

      String prompt = userQuestion;
       // Cosmic Injection
      if (profileData['cosmic_enabled'] == true) {
         final zodiac = profileData['zodiac_sign'] ?? (languageCode == 'en' ? "Unknown" : "Bilinmiyor");
         final date = DateTime.now().toString().split(' ')[0];
         
         if (languageCode == 'en') {
            prompt += "\n[COSMIC CONTEXT]: User Zodiac: $zodiac. Date: $date. Reflect cosmic energies in the answer.";
         } else {
            prompt += "\n[KOZMİK BAĞLAM]: Kullanıcının burcu: $zodiac. Tarih: $date. Kozmik enerjileri cevaba yansıt.";
         }
      }

      return await _callGroqApi(prompt, fullSystemPrompt);

    } catch (e) {
      return languageCode == 'en' ? "System overloaded. [ERROR: $e]" : "Sistem aşırı yüklendi. [ERROR: $e]";
    }
  }

  Future<String> analyzeDream(String dreamText, String languageCode) async {
    try {
      String systemPrompt;
      if (languageCode == 'en') {
        systemPrompt = "You are a dream interpreter. Interpret this dream with Carl Jung's archetype symbolism and a mystical language. Speak mysteriously like you are giving news from the future. Keep it short (Max 3 sentences). RESPONSE LANGUAGE: ONLY ENGLISH.";
      } else {
        systemPrompt = "Sen bir rüya tabircisisin. Bu rüyayı Carl Jung'un arketip sembolizmiyle ve mistik bir dille yorumla. Gelecekten bir haber veriyormuş gibi gizemli konuş. Kısa tut (Maks 3 cümle). YANIT DİLİ: SADECE TÜRKÇE.";
      }
      return await _callGroqApi(dreamText, systemPrompt);
    } catch (e) {
      return languageCode == 'en' ? "Subconscious frequencies interfere. Try again." : "Bilinçaltı frekansları parazitli. Tekrar dene.";
    }
  }

  Future<String> _callGroqApi(String userMessage, String systemPrompt) async {
    if (_apiKey.isEmpty) return "API Anahtarı eksik [ERR_NO_KEY].";

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": _model,
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userMessage}
          ],
          "temperature": 0.7,
          "max_tokens": 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        return content ?? "Sessizlik...";
      } else {
        return "Groq Bağlantı Hatası: ${response.statusCode}";
      }
    } catch (e) {
      return "Ağ Hatası: $e";
    }
  }

  Future<Map<String, dynamic>> _fetchUserProfile(String userId) async {
    try {
       final supabase = Supabase.instance.client;
       final data = await supabase
          .from('profiles')
          .select('bio_metrics')
          .eq('id', userId)
          .maybeSingle();
       
       if (data != null && data['bio_metrics'] != null) {
          return data['bio_metrics'] as Map<String, dynamic>;
       }
       return {};
    } catch (_) {
       return {};
    }
  }
}
