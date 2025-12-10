import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekno_mistik/core/models/profile_model.dart'; 

// --- Profile Notifier ---

class ProfileNotifier extends AsyncNotifier<AppProfile?> {
  // Initialize with null state, waiting for user data to load.
  @override
  Future<AppProfile?> build() async {
    return fetchProfile();
  }

  /// Fetches the user profile from Supabase.
  Future<AppProfile?> fetchProfile() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      return null;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final data = response;

      if (data != null) {
        // Note: JSON deserialization using generated factory methods
        return AppProfile.fromJson(data);
      }
      return null;
    } on PostgrestException catch (e) {
      // Log or handle Supabase specific errors
      debugPrint('Supabase error fetching profile: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  /// Creates a new profile or updates existing one. Used after onboarding consent.
  Future<void> saveProfile({
    required String username,
    required bool digitalConsent,
    required int age,
    required int height,
  }) async {
    state = const AsyncValue.loading();
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      state = AsyncValue.error('User not logged in.', StackTrace.current);
      return;
    }

    final newProfileData = {
      'id': userId,
      'username': username,
      'digital_consent': digitalConsent,
      // Store bio_metrics as a structured JSON object
      'bio_metrics': {'age': age, 'height': height},
    };

    try {
      // Upsert logic: If ID exists, update; otherwise, insert.
      await supabase
          .from('profiles')
          .upsert(newProfileData, onConflict: 'id')
          .select()
          .single();
      
      // Refresh state after successful save
      state = AsyncValue.data(await fetchProfile());
    } on PostgrestException catch (e) {
      state = AsyncValue.error('Supabase error: ${e.message}', StackTrace.current);
    } catch (e) {
      state = AsyncValue.error('Failed to save profile: $e', StackTrace.current);
    }
  }
}

// --- Profile Provider ---

final profileProvider = AsyncNotifierProvider<ProfileNotifier, AppProfile?> (
  ProfileNotifier.new,
);