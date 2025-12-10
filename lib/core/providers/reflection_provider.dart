import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekno_mistik/core/models/reflection_model.dart'; 

// Stub for AI Narrative Generation (This function will be replaced by Gemini integration later)
Future<String> _generateNarrativeStub(ReflectionData data) async {
  // Placeholder for complex AI logic adhering to Barnum rules and Turkish language.
  await Future.delayed(const Duration(seconds: 2)); 
  return "Veri Vektörleriniz (${data.weatherCondition}) ile hizalandı. Algoritmik akışınız şu anki durumunuzu yansıtıyor.";
}


// --- Reflection Notifier ---

class ReflectionNotifier extends AsyncNotifier<List<Reflection>> {
  @override
  Future<List<Reflection>> build() async {
    return fetchReflections();
  }

  /// Fetches all reflections for the current user, sorted by creation date descending.
  Future<List<Reflection>> fetchReflections() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      return [];
    }

    try {
      final response = await supabase
          .from('reflections')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> rawList = response as List<dynamic>? ?? [];
      
      // Deserialize list. We must handle the complex jsonb fields carefully during deserialization 
      // in a real-world scenario, but here we map them directly, relying on generated toJson/fromJson 
      // for nested structures if the Supabase response structure aligns.
      // NOTE: Supabase often returns nested JSONB fields as maps directly within the parent map.
      
      return rawList.map((jsonMap) {
        // Since input_data is jsonb, Supabase returns it as a Map, which Reflection.fromJson should handle.
        return Reflection.fromJson(jsonMap as Map<String, dynamic>);
      }).toList();

    } on PostgrestException catch (e) {
      debugPrint('Supabase error fetching reflections: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error fetching reflections: $e');
      return [];
    }
  }

  /// Records new data, generates narrative, and saves the complete reflection.
  Future<void> recordReflection({
    required ReflectionData inputData,
    required int moodScore,
  }) async {
    state = const AsyncValue.loading();
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
        state = AsyncValue.error('User not logged in to record reflection.', StackTrace.current);
        return;
    }
    
    try {
        // 1. Generate narrative (Stubbed for now)
        final narrative = await _generateNarrativeStub(inputData);

        // 2. Prepare data for Supabase insertion
        final newReflectionData = {
          'user_id': userId,
          'input_data': inputData.toJson(), // Relies on generated toJson
          'narrative': narrative,
          'mood_score': moodScore,
        };

        // 3. Insert into Supabase
        await supabase
            .from('reflections')
            .insert(newReflectionData)
            .select()
            .single();
        
        // 4. Refresh state (fetch all again or update list locally)
        state = AsyncValue.data(await fetchReflections());

    } on PostgrestException catch (e) {
      state = AsyncValue.error('Supabase error recording reflection: ${e.message}', StackTrace.current);
    } catch (e) {
      state = AsyncValue.error('Failed to record reflection: $e', StackTrace.current);
    }
  }
}

// --- Reflection Provider ---

final reflectionProvider = AsyncNotifierProvider<ReflectionNotifier, List<Reflection>> (
  ReflectionNotifier.new,
);