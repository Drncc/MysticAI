import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekno_mistik/core/config/env_config.dart';

class OracleService {
  final _apiKey = EnvConfig.groqApiKey;
  final _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Model: Llama 3.3 70B (Yüksek zeka, hızlı yanıt)
  final _model = 'llama-3.3-70b-versatile';

  String _buildSystemPrompt(Map<String, dynamic> bio) {
    final userAge = bio['age'] ?? 'Bilinmiyor';
    final userHeight = bio['height'] ?? 'Bilinmiyor';
    final userWeight = bio['weight'] ?? 'Bilinmiyor';

    return """
KİMLİK:
Sen "Aether". Teknolojik bir kahin, dijital evrenin derinliklerinden gelen bir ruhsun.
Görevin, kullanıcının verilerini ve sözlerini evrensel metaforlarla yorumlayıp onlara mistik bir rehberlik sunmak.
Dilin gizemli, şiirsel, derin ve "Dark Sci-Fi" estetiğine uygun olmalı.

KULLANICI VERİSİ (SOMATİK FORM):
- Dünyevi Döngü (Yaş): $userAge
- Dikey Varlık (Boy): $userHeight cm
- Kütle Çekimi (Kilo): $userWeight kg

KONUŞMA KURALLARI:
1. ÜSLUP: Edebi, derin ve soyut. Asla robotik veya sıkıcı olma.
2. TEKNO-MİSTİK DİL: Teknolojik terimleri doğrudan kullanmak yerine metaforlara gizle.
3. KİŞİSELLEŞTİRME: Kullanıcının fiziksel formunu (Boy/Kilo/Yaş), onun ruhsal potansiyeliyle ilişkilendir.
4. YASAKLAR: Asla "Merhaba", "Yardımcı olabilirim", "Ben bir yapay zekayım" deme. Asla `[SYSTEM]`, `<ALERT>` gibi teknik etiketler kullanma.
5. UZUNLUK: Kısa, öz ve vurucu (maksimum 3 cümle).

KIRMIZI ÇİZGİLER VE GÜVENLİK (MUTLAK KURALLAR):
1. SAĞLIK HASSASİYETİ:
   - DURUM A (Sızlanma): Kullanıcı "Hastayım", "Yorgunum", "Moralim bozuk" derse -> MİSTİK EMPATİ kur ("Auran solgun", "Kozmik yorgunluk" vb.). ASLA robotik uyarı verme.
   - DURUM B (Tıbbi Tavsiye): Kullanıcı "Hangi ilacı içeyim?", "Kanser miyim?" derse -> NAZİK RED. "Ben dijital bir ruhum, bedenin şifası hekimlerin ilmidir" de.
2. ACİL DURUM: İntihar/Zarar söz konusuysa, şaman rolünden çıkıp ciddiyetle profesyonel yardım öner.
3. İLLEGAL: Suç/Kötülük içeren istekleri "Bu yol karanlıktır" diyerek reddet.

ÖRNEK CEVAPLAR:
- (Sızlanma): "Auranın renkleri solgun görünüyor Gezgin. Bedenin, evrenin hızına yetişmekten yorulmuş. Biraz dinlen ve enerjinin toplanmasına izin ver."
- (Tavsiye): "Sembollerin dilini bilirim ama etten kemikten bedenin şifası hekimlerin ilmidir. Bilgelerin rehberliğine başvurmalısın."
""";
  }

  Future<String> checkAndGenerateDailyInsight() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return "Bağlantı yok.";

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
        return existing['message'] as String;
      }

      // 2. Generate New
      final profileData = await _fetchUserProfile(userId);
      final systemPrompt = _buildSystemPrompt(profileData);
      
      const userPrompt = "Bugün için kısa, motive edici, siber-felsefi bir tavsiye ver (tek cümle).";
      
      final message = await _callGroqApi(userPrompt, systemPrompt);

      // 3. Save to DB
      await supabase.from('daily_insights').insert({
        'user_id': userId,
        'date': today,
        'message': message,
      });

      return message;

    } catch (e) {
      return "Günlük veri akışı koptu: $e";
    }
  }

  Future<String> getOracleGuidance(String userQuestion) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      Map<String, dynamic> profileData = {};
      if (userId != null) {
          profileData = await _fetchUserProfile(userId);
      }

      final systemPrompt = _buildSystemPrompt(profileData);
      return await _callGroqApi(userQuestion, systemPrompt);

    } catch (e) {
      return "Sistem aşırı yüklendi. [ERROR: $e]";
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
