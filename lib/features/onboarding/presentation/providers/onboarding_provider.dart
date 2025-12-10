import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekno_mistik/core/models/profile_model.dart';

part 'onboarding_provider.g.dart';

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  void updateAge(String value) {
    if (value.isEmpty) {
      state = state.copyWith(age: null);
      return;
    }
    final age = int.tryParse(value);
    state = state.copyWith(age: age);
  }

  void updateHeight(String value) {
    if (value.isEmpty) {
      state = state.copyWith(height: null);
      return;
    }
    final height = int.tryParse(value);
    state = state.copyWith(height: height);
  }

  void updateWeight(String value) {
    if (value.isEmpty) {
      state = state.copyWith(weight: null);
      return;
    }
    final weight = int.tryParse(value);
    state = state.copyWith(weight: weight);
  }


}

class OnboardingState {
  final int? age;
  final int? height;
  final int? weight;

  const OnboardingState({this.age, this.height, this.weight});

  OnboardingState copyWith({int? age, int? height, int? weight}) {
    return OnboardingState(
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }

  bool get isValid => 
      age != null && age! > 0 &&
      height != null && height! > 0 &&
      weight != null && weight! > 0;
}

@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  FutureOr<void> build() {
    // idle state
  }

  Future<void> initializeSystem({
    required int age,
    required int height,
    required int weight,
  }) async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      
      // 1. SignIn Anonymously if needed
      if (supabase.auth.currentUser == null) {
        await supabase.auth.signInAnonymously();
      }

      final userId = supabase.auth.currentUser!.id;

      // 2. Insert Data
      final profileData = {
        'id': userId,
        'username': 'Gezgin_${userId.substring(0, 4)}',
        'digital_consent': true,
        'bio_metrics': {
          'age': age,
          'height': height,
          'weight': weight,
        }
      };

      await supabase.from('profiles').upsert(profileData).select().single();

      // 3. Success
      state = const AsyncValue.data(null);
      debugPrint("SYSTEM_INIT_SUCCESS: Profile created for $userId");
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

