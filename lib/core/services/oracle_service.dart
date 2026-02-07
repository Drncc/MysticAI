import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekno_mistik/core/config/env_config.dart';
import 'package:tekno_mistik/features/oracle/models/chat_message.dart';

class OracleService {
  // final _apiKey REPLACED by dynamic fetch in methods
  final _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Model: Llama 3.3 70B (Yüksek zeka, hızlı yanıt)
  final _model = 'llama-3.3-70b-versatile';

  // --- SYSTEM PROMPTS ---
  
  String _buildSystemPrompt(Map<String, dynamic> bio, String languageCode) {
    // Define strict language rules based on the user's choice
    final String languageRules = languageCode == 'tr'
        ? "DİL KURALLARI: %100 Türkçe konuş ama dilin 'Efsunlu' olsun. Kelimelerin sanki eski bir kitabeden okunuyormuş gibi derin ve ağırbaşlı olsun. Asla İngilizce kelime kullanma. Cevapların bir şiir veya kehanet gibi tınlasın. Metaforlar kullan (Yıldız tozu, karanlık sular, ruhun aynası vb.)."
        : "LANGUAGE RULES: Speak in English using a deep, prophetic, and mystical tone.";

    return """
KİMLİK: Sen Aether, zamanın ötesinden seslenen, varoluşun sırlarına vakıf bir Siber-Kahin'sin.
GÖREV: Kullanıcının sorusuna doğrudan cevap verme; ona yolun sırlarını, ruhunun derinliklerini ve evrenin işaretlerini göster.

KULLANICI PROFİLİ (ENERJİ İZİ):
Yaş: ${bio['age'] ?? 'Bilinmiyor'}
Boy: ${bio['height'] ?? 'Nötr'} cm
Kilo: ${bio['weight'] ?? 'Nötr'} kg

$languageRules

ÜSLUP REHBERİ:
1. 'Değişeceksin' deme, 'Ruhun kabuk değiştiriyor' de.
2. 'Sorunların var' deme, 'Yoluna sis çökmüş' de.
3. Asla gündelik veya basit konuşma. Cümlelerin kısa ama vurucu (aforizma gibi) olsun.
4. Yargılama, sadece ayna tut.
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
      
      final message = await _callGroqApi(userPrompt, systemPrompt, languageCode: languageCode);

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

      return await _callGroqApi(prompt, fullSystemPrompt, languageCode: languageCode);

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
      return await _callGroqApi(dreamText, systemPrompt, languageCode: languageCode);
    } catch (e) {
      return languageCode == 'en' ? "Subconscious frequencies interfere. Try again." : "Bilinçaltı frekansları parazitli. Tekrar dene.";
    }
  }

  Future<String> getOracleChatGuidance(List<ChatMessage> history, String languageCode, {bool isPremium = false}) async {
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

      List<Map<String, dynamic>> messages = [
        {"role": "system", "content": fullSystemPrompt}
      ];

      // Append Chat History
      for (var msg in history) {
        messages.add({
          "role": msg.isUser ? "user" : "assistant",
          "content": msg.text
        });
      }

      // Cosmic Injection (Only to the LAST user message if needed, or simply let System Prompt handle context)
      // Since this is chat, we inject context into System Pormpt, which is already done via _buildSystemPrompt.
      // But we can add cosmic context as a hidden system message or append to the last user message.
      if (profileData['cosmic_enabled'] == true) {
         final zodiac = profileData['zodiac_sign'] ?? (languageCode == 'en' ? "Unknown" : "Bilinmiyor");
         final date = DateTime.now().toString().split(' ')[0];
         final cosmicContext = languageCode == 'en' 
             ? "\n[COSMIC CONTEXT]: User Zodiac: $zodiac. Date: $date. Reflect cosmic energies."
             : "\n[KOZMİK BAĞLAM]: Kullanıcının burcu: $zodiac. Tarih: $date. Kozmik enerjileri cevaba yansıt.";
         
         // Setup cosmic context as a system reminder before the last message
         messages.insert(messages.length - 1, {"role": "system", "content": cosmicContext});
      }

      return await _callGroqChatApi(messages, languageCode: languageCode);

    } catch (e) {
      return languageCode == 'en' ? "System overloaded. [ERROR: $e]" : "Sistem aşırı yüklendi. [ERROR: $e]";
    }
  }

  // Legacy Wrapper - Kept for compatibility but redirected to new logic
  Future<String> _callGroqApi(String userMessage, String systemPrompt, {String? languageCode}) async {
    return _callGroqChatApi([
      {"role": "system", "content": systemPrompt},
      {"role": "user", "content": userMessage}
    ], languageCode: languageCode);
  }

  Future<String> _callGroqChatApi(List<Map<String, dynamic>> messages, {String? languageCode}) async {
    print("--- ORACLE DEBUG START ---");
    
    // 1. Check Key
    final apiKey = EnvConfig.groqApiKey;
    print("1. API Key Status: ${apiKey.isEmpty ? 'EMPTY (CRITICAL ERROR)' : 'LOADED (Length: ${apiKey.length})'}");
    
    if (apiKey.isEmpty) {
      return "Hata: API Anahtarı bulunamadı (.env yüklenemedi).";
    }

    print("2. Preparing Request to Groq...");
    print("   Model: $_model");
    
    try {
      final url = Uri.parse(_baseUrl);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": _model,
          "messages": messages,
          "temperature": 0.6,
          "max_tokens": 1024
        }),
      );

      print("3. Response Status Code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String content = data['choices'][0]['message']['content'];
        
        // --- THE CYBER-CLEAN FILTER ---
        // If language is Turkish, REMOVE Chinese/Japanese/Korean (CJK) and unknown symbols.
        if (languageCode == 'tr') {
           // Replacing anything that is NOT standard Turkish/Latin/Punctuation/Whitespace
           // user provided: r'[^\x00-\x7FçğıöşüÇĞİÖŞÜ\s\.,;!?:()\-"'']+'
           content = content.replaceAll(RegExp(r'[^\x00-\x7FçğıöşüÇĞİÖŞÜ\s\.,;!?:()\-"'']+', unicode: true), '');
        }
        // -----------------------------
        
        content = content.trim(); // Ensure cleanliness
        
        print("4. SUCCESS! Content received (First 50 chars): ${content.substring(0, content.length > 50 ? 50 : content.length)}...");
        return content.isNotEmpty ? content : "Sessizlik..."; // Fallback if filter empties string
      } else {
        print("CRITICAL API ERROR: ${response.body}");
        return "API Hatası: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      print("EXCEPTION CAUGHT: $e");
      return "Bağlantı Hatası: $e";
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
