import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekno_mistik/core/services/oracle_service.dart';
import 'package:tekno_mistik/features/profile/presentation/providers/history_provider.dart';

part 'oracle_provider.g.dart';

@riverpod
class OracleNotifier extends _$OracleNotifier {
  final _oracleService = OracleService();

  @override
  AsyncValue<String?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> seekGuidance(String prompt) async {
    state = const AsyncValue.loading();
    try {
      // 1. Get Guidance from Service
      final response = await _oracleService.getOracleGuidance(prompt);
      
      // 2. Save to Supabase
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        await supabase.from('readings').insert({
          'user_id': userId,
          'prompt': prompt,
          'response': response,
        });
        
        // Refresh history
        ref.invalidate(historyNotifierProvider);
      }

      // 3. Update State
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  void reset() {
      state = const AsyncValue.data(null);
  }
}
